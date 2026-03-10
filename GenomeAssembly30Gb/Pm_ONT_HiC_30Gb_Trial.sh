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

module use -a /g/data/if89/apps/modulefiles/
module load hifiasm

# Run Hifiasm for haplotype-resolved assembly
hifiasm -o /g/data/xf3/ls9057/Pmelanocephala/Pm_ONT_30Gb_trial.asm --ont -t 24 --h1 /g/data/xf3/ls9057/Pmelanocephala/Pm_HiC/638001_LibID640663_PP_BRF_AAHCM7VM5_TCAGCATC-AAGGAGCG_S1_R1_001.fastq.gz --h2 /g/data/xf3/ls9057/Pmelanocephala/Pm_HiC/638001_LibID640663_PP_BRF_AAHCM7VM5_TCAGCATC-AAGGAGCG_S1_R2_001.fastq.gz /scratch/xf3/ls9057/Pmelanocephala/638001_LibID640766_PP_BRF_PBI90827_ONTPromethION_fastq_pass/Pm_ONT_longest_30gb.fastq.gz


