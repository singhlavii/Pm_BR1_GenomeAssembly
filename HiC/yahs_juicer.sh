#!/bin/bash
#PBS -q normal
#PBS -l mem=100GB
#PBS -l walltime=20:00:00
#PBS -l ncpus=8
#PBS -l jobfs=300GB
#PBS -l wd
#PBS -l storage=scratch/fa63+gdata/fa63+scratch/xf3+gdata/xf3+gdata/if89
#PBS -P xf3
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xe

module load samtools/1.9
module load java/jdk-8.40

export PATH=$PATH:/g/data/xf3/common/softwares/yahs-1.2.2

JUICER_JAR=/g/data/xf3/ls9057/software/juicer_tools.1.9.9_jcuda.0.8.jar
ASSEMBLY=/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_30Gb_filtered.hap2.fa
BAM=/scratch/xf3/ls9057/Pmelanocephala/HiC/hicpro_output_hap2/bowtie_results/bwt2/Pm_HiC_sample/Pm_HiC_sample_hap2.bwt2pairs.bam
OUTDIR=/scratch/xf3/ls9057/Pmelanocephala/yahs_hap2

mkdir -p $OUTDIR
cd $OUTDIR

yahs -o Pm_hap2_yahs --telo-motif TTAGGG $ASSEMBLY $BAM

juicer pre -a -o Pm_hap2_out_JBAT Pm_hap2_yahs.bin Pm_hap2_yahs_scaffolds_final.agp $ASSEMBLY.fai >out_JBAT.log 2>&1

(java -jar -Xmx32G $JUICER_JAR pre Pm_hap2_out_JBAT.txt out_JBAT.hic.part <(cat out_JBAT.log | grep PRE_C_SIZE | awk '{print $2" "$3}')) && (mv out_JBAT.hic.part out_JBAT.hic)
