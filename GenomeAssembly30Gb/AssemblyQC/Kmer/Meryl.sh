#!/bin/bash
#PBS -q normal
#PBS -P xf3
#PBS -l ncpus=16
#PBS -l mem=192GB
#PBS -l jobfs=100GB
#PBS -l walltime=12:00:00
#PBS -l wd
#PBS -l storage=scratch/xf3+gdata/xf3+gdata/if89
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

module use /g/data/if89/apps/modulefiles
module load meryl/1.4.1
module load merqury/1.3

MERQURY=/scratch/xf3/ls9057/Pmelanocephala/scripts/merqury.sh
READS=/g/data/xf3/ls9057/Pmelanocephala/fastq/Pm_ONT_longest_30gb.fastq.gz
HAP12=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap12_3ddna_v2_20260829.fasta
HAP1=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap1_3ddna_v2_20260829.fasta
HAP2=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap2_3ddna_v2_20260829.fasta
OUTDIR=/scratch/xf3/ls9057/Pmelanocephala/merqury

mkdir -p $OUTDIR
cd $OUTDIR

# Step 1 — Build k-mer database
meryl k=21 count memory=180 threads=16 output reads.k21.meryl $READS
