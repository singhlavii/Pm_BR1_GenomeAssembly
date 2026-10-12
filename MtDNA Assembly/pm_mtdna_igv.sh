#!/bin/bash
#PBS -q normal
#PBS -P xf3
#PBS -l ncpus=16
#PBS -l mem=32GB
#PBS -l jobfs=20GB
#PBS -l walltime=01:00:00
#PBS -l wd
#PBS -l storage=scratch/xf3+gdata/xf3+gdata/if89
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

# Map the mtDNA reads back to both circular candidates, for inspection in IGV
set -xeo pipefail

module use -a /g/data/if89/apps/modulefiles
module load minimap2/2.31
module load samtools
module load seqkit

DIR=/scratch/xf3/ls9057/Pmelanocephala/mtdna
REF=${DIR}/Pm_hap12_v2_20260829_mtDNA.fasta
# the 10% subsample that ptg000001c was assembled from (same reads used for both candidates)
READS=${DIR}/map_ONT/mito.mtDNA.20-120k.fastq
OUT=${DIR}/assembly/igv

mkdir -p "$OUT"
cd "$OUT"

# candidate 1: h1tg000047c from the genome assembly
samtools faidx "$REF" h1tg000047c > h1tg000047c.mtDNA_candidate.fasta
# candidate 2: ptg000001c from the baited hifiasm run (10% subsample)
seqkit grep -p ptg000001c ${DIR}/assembly/cov_test/p0.1/circular.fasta > ptg000001c.mtDNA_candidate.fasta

for NAME in h1tg000047c ptg000001c; do
  # index the candidate (IGV needs the .fai)
  samtools faidx ${NAME}.mtDNA_candidate.fasta

  # map the mtDNA reads back to the candidate
  minimap2 -t 12 -ax map-ont ${NAME}.mtDNA_candidate.fasta "$READS" \
  | samtools sort -@ 4 -T "$PBS_JOBFS/${NAME}" -O BAM -o ${NAME}.mtDNA_candidate.bam
  samtools index ${NAME}.mtDNA_candidate.bam
done

