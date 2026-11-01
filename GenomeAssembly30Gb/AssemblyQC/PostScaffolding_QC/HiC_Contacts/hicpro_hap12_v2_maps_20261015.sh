#!/bin/bash
#PBS -q normal
#PBS -P xf3
#PBS -l ncpus=48
#PBS -l mem=190GB
#PBS -l jobfs=100GB
#PBS -l walltime=12:00:00
#PBS -l wd
#PBS -l storage=scratch/xf3+gdata/xf3
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

module load singularity

cd /scratch/xf3/ls9057/Pmelanocephala/HiC

singularity exec \
  --bind /scratch/xf3/ls9057/Pmelanocephala/HiC:/scratch/xf3/ls9057/Pmelanocephala/HiC \
  /g/data/xf3/miniconda/HiC-Pro_latest.sif \
  HiC-Pro \
  -i HiC_input_allvp \
  -o hicpro_output_hap12_v2_20261013 \
  -c config_hap12_v2_20260829.txt \
  -s build_contact_maps -s ice_norm
