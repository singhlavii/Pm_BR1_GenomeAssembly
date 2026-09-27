#!/bin/bash
#PBS -q normal
#PBS -P xf3
#PBS -l ncpus=16
#PBS -l mem=128GB
#PBS -l jobfs=100GB
#PBS -l walltime=24:00:00
#PBS -l wd
#PBS -l storage=scratch/xf3+gdata/xf3+gdata/if89
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

module use /g/data/if89/apps/modulefiles
module load meryl/1.4.1
module load merqury/1.3

MERQURY_TOOL=/g/data/if89/apps/merqury/1.3/merqury.sh
HAP12=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap12_3ddna_v2_20260829.fasta
HAP1=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap1_3ddna_v2_20260829.fasta
HAP2=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap2_3ddna_v2_20260829.fasta
MERYL_DB=/scratch/xf3/ls9057/Pmelanocephala/merqury/reads.k21.meryl
OUTDIR=/scratch/xf3/ls9057/Pmelanocephala/merqury

cd $OUTDIR

# Meryl already done — skip to merqury
$MERQURY_TOOL $MERYL_DB $HAP12 Pm_hap12_3ddna_v2_merqury
$MERQURY_TOOL $MERYL_DB $HAP1 Pm_hap1_3ddna_v2_merqury
$MERQURY_TOOL $MERYL_DB $HAP2 Pm_hap2_3ddna_v2_merqury

echo "Done!"
