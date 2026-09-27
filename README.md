## Genome Assembly of *Puccinia melanocephala* (Internal isolate ID: BR1)
Codes used for assembling Puccinia melanocephala (BR1) genome as part of my PhD. I have used Claude (Sonnet 4.6) to help with some codes (cross checking). 

1. DataDownload
2. PreProcessingQC
3. GenomeAssembly30Gb
4. HiC

### 1. DataDownload

```BioplatformsDataPortal``` > ```MovingtoNCI``` > ```DeCompressingFiles```

### 2. PreProcessingQC

```Nanoplot``` > ```Seqkit``` > ```Jellyfish``` > ```SubSampling30Gb```

### 3. GenomeAssembly30Gb

```Pm_ONT_HiC_30Gb_Trial.sh``` > 

```AssemblyQC``` : ```Pm_ONT_30Gb_trial_asm_Seqkit.sh``` > ```contig_lengths_sorted_hap1.sh``` > 

```CoverageQC``` : ```CoverageQC.sh``` > ```20260408_BamtoCov.txt``` > ```KaryoplotR.R```
