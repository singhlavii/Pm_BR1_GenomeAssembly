#!/bin/bash
#PBS -q normal
#PBS -P xf3
#PBS -l ncpus=48
#PBS -l mem=180GB
#PBS -l jobfs=100GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=scratch/fa63+gdata/fa63+scratch/xf3+gdata/xf3
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

bash /g/data/xf3/ls9057/Pmelanocephala/juicer_3ddna/juicer_3ddna.sh \
  Pm_hap12_reorder \
  Arima4 \
  /scratch/xf3/ls9057/Pmelanocephala/post_dgenies/Pm_hap12_v1_reorder.fa \
  /scratch/xf3/ls9057/Pmelanocephala/HiC/HiC_input/Pm_HiC_sample/Pm_HiC_sample_R1.fastq.gz \
  /scratch/xf3/ls9057/Pmelanocephala/HiC/HiC_input/Pm_HiC_sample/Pm_HiC_sample_R2.fastq.gz \
  /g/data/xf3/ls9057/Pmelanocephala/juicer_3ddna_v2
