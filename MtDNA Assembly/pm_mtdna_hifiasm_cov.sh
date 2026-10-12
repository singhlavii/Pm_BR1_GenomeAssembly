#!/bin/bash
#PBS -q normal
#PBS -P xf3
#PBS -l ncpus=24
#PBS -l mem=64GB
#PBS -l jobfs=20GB
#PBS -l walltime=04:00:00
#PBS -l wd
#PBS -l storage=scratch/xf3+gdata/xf3+gdata/if89
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

# Run hifiasm on smaller subsamples of the mito reads to try to get a circular contig
set -xeo pipefail

module use -a /g/data/if89/apps/modulefiles
module load hifiasm/0.25.0
module load seqkit

DIR=/scratch/xf3/ls9057/Pmelanocephala/mtdna
READS=${DIR}/map_ONT/mito.mtDNA.20-120k.fastq      # length-filtered, NOT subsampled (481 Mb)
ASM=${DIR}/assembly/cov_test

mkdir -p "$ASM"
cd "$ASM"

SUMMARY=${ASM}/summary.txt
echo -e "proportion\treads\tbases\tcontig\tlength" > "$SUMMARY"

# fraction of reads to keep (0.3 was used before)
for P in 0.01 0.02 0.05 0.1; do
  D=p${P}
  mkdir -p $D
  seqkit sample -s 11 -p $P "$READS" > $D/reads.fastq
  stats=$(seqkit stats -T $D/reads.fastq | awk 'NR==2{print $4"\t"$5}')

  # '|| true' so one failed run doesn't stop the others
  hifiasm --ont --primary -t 24 -f 0 -o $D/hifiasm $D/reads.fastq > $D/hifiasm.log 2>&1 || true
  if [[ ! -s $D/hifiasm.p_ctg.gfa ]]; then
    echo -e "${P}\t${stats}\tFAILED\t-" >> "$SUMMARY"
    continue
  fi

  awk '/^S/ {print ">"$2"\n"$3}' $D/hifiasm.p_ctg.gfa > $D/p_ctg.fasta
  seqkit fx2tab -n -l $D/p_ctg.fasta | awk -v p=$P -v s="$stats" '{print p"\t"s"\t"$1"\t"$2}' >> "$SUMMARY"

  # keep circular contigs (names ending in 'c')
  seqkit grep -r -p 'c$' $D/p_ctg.fasta > $D/circular.fasta || true
done

set +x
echo "===== SUMMARY (contig names ending in 'c' are circular) ====="
column -t "$SUMMARY"
