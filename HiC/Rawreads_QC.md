**Hi-C raw reads QC**

**Note from BRF**: When utilizing libraries generated with the Arima Hi-C library prep kit, we suggest trimming 5 bases from the 5’ end of both read 1 and read 2 before using the Arima mapping pipeline.
The purpose of this modification is to remove over-represented 3bp molecular barcode UMI sequences and 2 dark bases from the 5’ end of reads, resulting in improved results.

I also wanted to trim off adapters and do general QC. I used TrimGalore

```
#!/bin/bash
#PBS -l ncpus=24
#PBS -l mem=90GB
#PBS -l jobfs=20GB
#PBS -q normal
#PBS -P fa63
#PBS -l walltime=12:00:00
#PBS -l storage=gdata/xf3+scratch/xf3+gdata/fa63+scratch/fa63+gdata/if89
#PBS -l wd
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

set -xue
source /g/data/xf3/miniconda/etc/profile.d/conda.sh
conda activate /g/data/xf3/miniconda/envs/trim-galore

cd /scratch/xf3/ls9057/Pmelanocephala/HiC

# Use TrimGalore
trim_galore --paired \
  --cores 4 \
  --clip_R1 5 \
  --clip_R2 5 \
  Pm_HiC_R1.fastq.gz Pm_HiC_R2.fastq.gz \
  -o trimmed_output/
```
