#!/bin/bash
#PBS -l ncpus=24
#PBS -l mem=96GB
#PBS -l jobfs=200GB
#PBS -q normal
#PBS -P fa63
#PBS -l walltime=9:00:00
#PBS -l storage=gdata/xf3+scratch/xf3+gdata/fa63+scratch/fa63+gdata/if89
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

#Code edited with Claude (Sonnet v4.6)
#Successfully installed numpy-2.4.6 scipy-1.17.1
set -xe
module load samtools/1.23.1
module load bowtie2
module load python3-as-python
source /g/data/xf3/ls9057/software/hicpro_venv/bin/activate
 
# Environment setup
export PATH=$PATH:/g/data/xf3/ls9057/software/HiC-Pro/bin/utils   # adjust to HiC-Pro install, I have a git clone version here since i wont run hic pro itself

# --- Paths: edit these ---
WORKDIR=/scratch/xf3/ls9057/Pmelanocephala/HiC
REF1=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_30Gb_filtered.hap1.fa
REF2=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_30Gb_filtered.hap2.fa

cd $WORKDIR

# --- Haplotype 1 ---
mkdir -p bowtie2_index_hap1

digest_genome.py -r ^GATC G^ANTC T^TAA C^TNAG -o hap1.digested.bed $REF1

bowtie2-build $REF1 bowtie2_index_hap1/hap1 --threads 24

samtools faidx $REF1
cut -f1,2 ${REF1}.fai > hap1.chrom.sizes

# --- Haplotype 2 ---
mkdir -p bowtie2_index_hap2

digest_genome.py -r ^GATC G^ANTC T^TAA C^TNAG -o hap2.digested.bed $REF2

bowtie2-build $REF2 bowtie2_index_hap2/hap2 --threads 24

samtools faidx $REF2
cut -f1,2 ${REF2}.fai > hap2.chrom.sizes

echo "Genome prep complete for both haplotypes."


