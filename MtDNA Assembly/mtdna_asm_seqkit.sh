#!/bin/bash
#PBS -q normal
#PBS -P xf3
#PBS -l ncpus=8
#PBS -l mem=16GB
#PBS -l walltime=02:00:00
#PBS -l wd
#PBS -l storage=gdata/xf3+scratch/xf3+gdata/if89
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xeo pipefail

module use -a /g/data/if89/apps/modulefiles
module load samtools
module load seqkit        # or activate the conda env that has seqkit

DIR=/scratch/xf3/ls9057/Pmelanocephala/mtdna
REF=${DIR}/Pm_hap12_v2_20260829_mtDNA.fasta
BAM=${DIR}/map_ONT/Pm_hap12_v2_20260829_mtDNA.sorted.bam
OUT=${DIR}/map_ONT/mito

# mtDNA contigs = every sequence whose name starts with 'h' (h1tg..., h2tg...)
[[ -s "${REF}.fai" ]] || samtools faidx "$REF"
MT_IDS=$(awk '$1 ~ /^h/ {print $1}' "${REF}.fai")
[[ -n "$MT_IDS" ]] || { echo "ERROR: no contigs starting with 'h' in $REF"; exit 1; }
echo "mtDNA contigs: $(echo $MT_IDS | wc -w)"
awk '$1 ~ /^h/ {print $1, $2; s+=$2} END {print "total mtDNA contig length:", s, "bp"}' "${REF}.fai"

# extract reads mapped to the mtDNA contigs (these are considered mitochondrial reads)
# -b = BAM output; -F 0x904 = primary alignments only, so each read is output once
samtools view -b -F 0x904 "$BAM" $MT_IDS -o ${OUT}.mtDNA.bam
samtools fastq ${OUT}.mtDNA.bam > ${OUT}.mtDNA.fastq

# filter mtDNA reads by length
seqkit seq --threads 8 --max-len 120000 --min-len 20000 ${OUT}.mtDNA.fastq > ${OUT}.mtDNA.20-120k.fastq

# subsample to ~700x to be memory efficient during assembly
seqkit sample -s 11 -p 0.3 ${OUT}.mtDNA.20-120k.fastq > ${OUT}.mtDNA.20-120k.subsamp0.3.fastq

# read counts and total bases at each stage (check the subsample is ~700x)
seqkit stats -T ${OUT}.mtDNA.fastq ${OUT}.mtDNA.20-120k.fastq ${OUT}.mtDNA.20-120k.subsamp0.3.fastq