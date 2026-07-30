#!/bin/bash

##### SETTINGS #####
sample=$1
re=$2
ref=$3
hic1=$4
hic2=$5
indir=$6

source /g/data/xf3/miniconda/etc/profile.d/conda.sh
module load bwa/0.7.17 python2 parallel/20191022 samtools/1.9

juicerdir=/g/data/xf3/ls9057/software/juicer/CPU
bioawkdir=/g/data/xf3/ls9057/software/bioawk
dir3ddna=/g/data/xf3/ls9057/software/3d-dna
lastzdir=/g/data/xf3/ls9057/software/lastz-1.04.52/src

######################
### pipeline start ###
######################

wdir=${indir}/${sample}
mkdir -p $wdir
mkdir -p ${wdir}/references ${wdir}/fastq ${wdir}/3d-dna

ln -s $ref ${wdir}/references/.
bwa index ${wdir}/references/$(basename $ref)

ln -s $hic1 ${wdir}/fastq/.
ln -s $hic2 ${wdir}/fastq/.
ln -s $juicerdir ${wdir}/scripts

export PATH=$PATH:${bioawkdir}
bioawk -c fastx '{print $name"\t"length($seq)}' ${wdir}/references/$(basename $ref) > ${wdir}/chrom.sizes

echo "python2 /g/data/xf3/ls9057/software/juicer/misc/generate_site_positions.py $re $sample ${wdir}/references/$(basename $ref)"
python2 /g/data/xf3/ls9057/software/juicer/misc/generate_site_positions.py $re $sample ${wdir}/references/$(basename $ref)
mv ${sample}_${re}.txt $wdir

##################
### run juicer ###
##################

bash ${wdir}/scripts/juicer.sh -S early --assembly -D $wdir -d $wdir -g $sample -z ${wdir}/references/$(basename $ref) -y ${wdir}/${sample}_${re}.txt -p ${wdir}/chrom.sizes -t 48 -b $re

##################
### run 3d-dna ###
##################

export PATH=$PATH:${lastzdir}
cd ${wdir}/3d-dna
bash ${dir3ddna}/run-asm-pipeline.sh --mode diploid --rounds 1 --sort-output ${wdir}/references/$(basename $ref) ${wdir}/aligned/merged_nodups.txt
