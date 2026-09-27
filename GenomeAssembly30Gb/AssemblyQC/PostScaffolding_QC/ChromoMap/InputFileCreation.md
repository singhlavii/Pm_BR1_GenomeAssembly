## Input File Creation for ChromoMap Package in R

Run this on NCI

1. Use the ```FindTelomeres.py``` script to identify telomeres. This is an example:
```
python3 /scratch/xf3/ls9057/Pmelanocephala/scripts/FindTelomeres.py \
  /scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap12_3ddna_20260820.fa \
  > /scratch/xf3/ls9057/Pmelanocephala/scripts/telomeres_hap12_3ddna_20260820.txt
```

2. Create a file with chromosome sizes:
```
module load samtools/1.9
samtools faidx /scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap12_3ddna_20260820.fa

awk '{print $1"\t1\t"$2}' \
  /scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap12_3ddna_20260820.fa.fai \
  > /scratch/xf3/ls9057/Pmelanocephala/scripts/chrom_sizes_3ddna_20260820.txt
```

3. Then run ```make_telomere_annotation.py``` in this folder.

4. Input your Chromosome sizes and telomere annotation files in ```chromoMap_combined.R``` in this folder. 
