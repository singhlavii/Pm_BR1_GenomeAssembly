#!/bin/bash
#PBS -q normal
#PBS -P xf3
#PBS -l ncpus=24
#PBS -l mem=64GB
#PBS -l jobfs=100GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=scratch/xf3+gdata/xf3+gdata/if89
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xe

module use /g/data/if89/apps/modulefiles
module load genometools/1.6.5
module load LTR_retriever/2.9.4

LTR_FINDER_PARALLEL=/g/data/xf3/ls9057/software/LTR_FINDER_parallel/LTR_FINDER_parallel

GENOMEDIR=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb
OUTDIR=/scratch/xf3/ls9057/Pmelanocephala/LAI

mkdir -p $OUTDIR

for hap in hap1 hap2; do
    genome=${GENOMEDIR}/Pm_${hap}_3ddna_v2_20260829.fasta
    prefix=Pm_${hap}_3ddna_v2_20260829.fasta

    cd $OUTDIR

    # Step 1 — Build suffix array (output to OUTDIR)
    gt suffixerator -db $genome -indexname ${OUTDIR}/${prefix} \
      -tis -suf -lcp -des -ssp -sds -dna

    # Step 2 — LTRharvest (output to OUTDIR)
    gt ltrharvest -index ${OUTDIR}/${prefix} \
      -minlenltr 100 -maxlenltr 7000 \
      -mintsd 4 -maxtsd 6 \
      -motif TGCA -motifmis 1 \
      -similar 85 -vic 10 -seed 20 -seqids yes \
      > ${OUTDIR}/${prefix}.harvest.scn

    # Step 3 — LTR_FINDER_parallel (run from OUTDIR so output goes there)
    perl $LTR_FINDER_PARALLEL -seq $genome -threads 24 \
      -harvest_out -size 1000000 -time 300

    # Step 4 — Combine results (all files now in OUTDIR)
    cat ${OUTDIR}/${prefix}.harvest.scn \
        ${OUTDIR}/${prefix}.finder.combine.scn \
        > ${OUTDIR}/${prefix}.rawLTR.scn

    # Step 5 — LTR_retriever
    LTR_retriever -genome $genome \
      -inharvest ${OUTDIR}/${prefix}.rawLTR.scn \
      -threads 24

done

echo "Done!"
