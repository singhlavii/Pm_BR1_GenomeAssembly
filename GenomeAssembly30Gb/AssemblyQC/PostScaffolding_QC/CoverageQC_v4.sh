#!/bin/bash
#PBS -l ncpus=24
#PBS -l mem=180GB
#PBS -l jobfs=200GB
#PBS -q normal
#PBS -P xf3
#PBS -l walltime=24:00:00
#PBS -l storage=gdata/xf3+scratch/xf3+gdata/fa63+scratch/fa63+gdata/if89
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xue

module load bedtools/2.31.0

cd /scratch/xf3/ls9057/Pmelanocephala

# compute coverage
cut -f1,2 Pm_asm_30Gb/Pm_hap12_3ddna_v2_20260829.fasta.fai > assemblyQC/genome_file_v2_20260829.txt
bedtools makewindows -g assemblyQC/genome_file_v2_20260829.txt -w 10000 -s 8000 > assemblyQC/genome_file_v2_20260829.w10ks8k.bed

