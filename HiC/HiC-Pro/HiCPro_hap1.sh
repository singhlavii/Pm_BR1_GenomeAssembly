#!/bin/bash
#PBS -q normal
#PBS -P fa63
#PBS -l ncpus=24
#PBS -l mem=180GB
#PBS -l jobfs=300GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=scratch/fa63+gdata/fa63+scratch/xf3+gdata/xf3+gdata/if89
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xe
cd /scratch/xf3/ls9057/Pmelanocephala/HiC
module load singularity

singularity exec --bind $PWD:$PWD /g/data/xf3/miniconda/HiC-Pro_latest.sif \
  HiC-Pro -i HiC_input -o hicpro_output_hap1 -c config_hap1.txt
