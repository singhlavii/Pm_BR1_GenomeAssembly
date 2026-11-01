#!/bin/bash
#PBS -l ncpus=24
#PBS -l mem=96GB
#PBS -l jobfs=200GB
#PBS -q normal
#PBS -P xf3
#PBS -l walltime=9:00:00
#PBS -l storage=gdata/xf3+scratch/xf3+gdata/if89
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xe

module load samtools/1.23.1
module load bowtie2
module load python3-as-python
source /g/data/xf3/ls9057/software/hicpro_venv/bin/activate

export PATH=$PATH:/g/data/xf3/ls9057/software/HiC-Pro/bin/utils

# --- Paths ---
WORKDIR=/scratch/xf3/ls9057/Pmelanocephala/HiC
REF=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap12_3ddna_v2_20260829.fasta
SAMPLE=v2_20260829

cd $WORKDIR

# --- Prep steps ---
mkdir -p bowtie2_index_hap12_${SAMPLE}

digest_genome.py -r ^GATC G^ANTC T^TAA C^TNAG \
  -o hap12_${SAMPLE}.digested.bed $REF

bowtie2-build $REF \
  bowtie2_index_hap12_${SAMPLE}/hap12_${SAMPLE} \
  --threads 24

samtools faidx $REF
cut -f1,2 ${REF}.fai > hap12_${SAMPLE}.chrom.sizes

echo "Done! Output files:"
echo "  ${WORKDIR}/hap12_${SAMPLE}.digested.bed"
echo "  ${WORKDIR}/bowtie2_index_hap12_${SAMPLE}/"
echo "  ${WORKDIR}/hap12_${SAMPLE}.chrom.sizes"
