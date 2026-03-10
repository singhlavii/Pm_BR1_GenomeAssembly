#!/bin/bash
#PBS -l ncpus=1
#PBS -l mem=4GB
#PBS -l jobfs=200GB
#PBS -q normal
#PBS -P xf3
#PBS -l walltime=1:00:00
#PBS -l storage=gdata/xf3+scratch/xf3+gdata/fa63+scratch/fa63+gdata/if89
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xue

cd /g/data/xf3/ls9057/Pmelanocephala

# Input
GFA="Pm_ONT_30Gb_trial.asm.hic.hap1.p_ctg.gfa"
OUTFILE="Pm_30Gb.asm.hic.hap1.contig_lengths_sorted.txt"
FASTA="Pm_30Gb.asm.hic.hap1.p_ctg.fasta"

##Sonnet 4.6 used for code below

# Check input file exists before doing anything
if [ ! -f "$GFA" ]; then
    echo "ERROR: Input file '$GFA' not found"
    exit 1
fi

echo "Running contig length extraction on: $GFA"
echo "Started: $(date)"
echo ""

# Convert GFA to FASTA and extract lengths in a single pass
echo "Converting GFA to FASTA and extracting contig lengths..."
awk '
/^S/ {
    print ">"$2"\n"$3 > "'"$FASTA"'"
    print $2"\t"length($3)
}
' $GFA | sort -t$'\t' -k2 -rn > $OUTFILE

# Check both outputs were actually created
if [ ! -f "$FASTA" ]; then
    echo "ERROR: FASTA conversion failed"
    exit 1
fi

if [ ! -s "$OUTFILE" ]; then
    echo "ERROR: Contig length extraction failed or no contigs found"
    exit 1
fi

echo "FASTA saved to: $FASTA"
echo ""

# Summary stats
echo "===== Summary ====="
echo "Total contigs:    $(wc -l < $OUTFILE)"
echo ""
echo "Top 10 largest contigs:"
head -10 $OUTFILE
echo ""
echo "Total assembly size:"
awk '{sum+=$2} END{printf "%.2f Mb\n", sum/1000000}' $OUTFILE
echo ""
echo "Contigs > 1Mb:   $(awk '$2 > 1000000' $OUTFILE | wc -l)"
echo "Contigs > 10Mb:  $(awk '$2 > 10000000' $OUTFILE | wc -l)"
echo "Contigs > 100Mb: $(awk '$2 > 100000000' $OUTFILE | wc -l)"
echo ""
echo "Finished: $(date)"
echo "Full results saved to: $OUTFILE"
echo "FASTA file saved to:   $FASTA"

