#!/bin/bash
#PBS -l ncpus=24
#PBS -l mem=180GB
#PBS -l jobfs=200GB
#PBS -q normal
#PBS -P fa63
#PBS -l walltime=24:00:00
#PBS -l storage=gdata/xf3+scratch/xf3+gdata/fa63+scratch/fa63+gdata/if89
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xue

module load bedtools/2.31.0
module load samtools/1.22

module use -a /g/data/if89/apps/modulefiles/
module load minimap2/2.30

cd /scratch/xf3/ls9057/Pmelanocephala/638001_LibID640766_PP_BRF_PBI90827_ONTPromethION_fastq_pass/

# align reads to assembly
minimap2 -t 24 -ax map-ont Pm_asm/Pm_ONT_30Gb_trial.hap12.asm.fa Pm_ONT_longest_30gb.fastq.gz | samtools sort -@24 -O BAM -o Pm_ONT_30Gb_trial.hap12.asm.bam 
samtools index -@24 Pm_ONT_30Gb_trial.hap12.asm.bam

# compute coverage
samtools faidx Pm_asm/Pm_ONT_30Gb_trial.hap12.asm.fa
cut -f1,2 Pm_asm/Pm_ONT_30Gb_trial.hap12.asm.fa.fai > genome_file.txt
bedtools makewindows -g genome_file.txt -w 10000 -s 8000 > genome_file.w10ks8k.bed

