#!/bin/bash
#PBS -l ncpus=24
#PBS -l mem=96GB
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
module use -a /g/data/if89/apps/modulefiles
module load seqkit/2.9.0

cd /g/data/xf3/ls9057/Pmelanocephala

INPUT="Pm_ONT_30Gb_trial.asm.hic.p_ctg.gfa"

# Convert GFA to FASTA
awk '/^S/{print ">"$2"\n"$3}' ${INPUT} > Pm_ONT_30Gb_trial.asm.fa

# Get stats
seqkit stats -a -j 24 Pm_ONT_30Gb_trial.asm.fa > Pm_ONT_30Gb_trial.asm.stats.txt
