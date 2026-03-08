#!/bin/bash
#PBS -l ncpus=24
#PBS -l mem=180GB
#PBS -l jobfs=200GB
#PBS -q normal
#PBS -P xf3
#PBS -l walltime=12:00:00
#PBS -l storage=gdata/xf3+scratch/xf3+gdata/fa63+scratch/fa63+gdata/if89
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xue
module use -a /g/data/if89/apps/modulefiles/
module load seqkit/2.9.0

cd /scratch/xf3/ls9057/Pmelanocephala/638001_LibID640766_PP_BRF_PBI90827_ONTPromethION_fastq_pass

INPUT="Pm_ONT_mergedfq.fastq.gz"
SORTED="sorted.fastq.gz"
OUTPUT="Pm_ONT_longest_30gb.fastq.gz"
TARGET_BASES=30000000000

# Step 1: Sort by length descending
seqkit sort -l -r -j 24 ${INPUT} -o ${SORTED}

# Step 2: Take longest reads until 30 Gb
seqkit head -b ${TARGET_BASES} ${SORTED} -o ${OUTPUT}

# Clean up intermediate file
rm ${SORTED}
