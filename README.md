## Genome Assembly of *Puccinia melanocephala* (Internal isolate ID: BR1)
Codes used for assembling *Puccinia melanocephala* (BR1) genome as part of my PhD. I have used Claude (Sonnet 4.6) to help with some codes, mainly interpreting error logs and software manuals/usage. 

1. DataDownload
2. PreProcessingQC
3. GenomeAssembly30Gb
4. HiC
5. Assembly QC post Scaffolding

### 1. DataDownload

```BioplatformsDataPortal``` > ```MovingtoNCI``` > ```DeCompressingFiles```

### 2. PreProcessingQC

```Nanoplot``` > ```Seqkit``` > ```Jellyfish``` > ```SubSampling30Gb```

### 3. GenomeAssembly30Gb

```Pm_ONT_HiC_30Gb_Trial.sh``` > 

AssemblyQC: ```Pm_ONT_30Gb_trial_asm_Seqkit.sh``` > ```contig_lengths_sorted_hap1.sh``` > 

CoverageQC : ```CoverageQC.sh``` > ```20260408_BamtoCov.txt``` > ```KaryoplotR.R``` >

Blast_mtDNA_contamination >  blast-snake : refer to ```usage.md```

### 4. HiC

```Rawreads_QC.md``` >

HiC-Pro : ```HiC-Pro_prep.md``` > ```HiCPro_prep.sh``` > ```config_hap1.txt``` > ```HiCPro_hap1.sh``` >

```yahs_juicer.sh``` > ```Post_juicebox_edits.md``` >

3d-dna > edit ``` juicer_3ddna.sh ``` > ```run_juicer_3ddna.sh``` > ```Post_juicebox_edits.md```

5. Assembly QC post Scaffolding
   
I then proceeded to do assembly QC and stored codes in GenomeAssembly30GB > AssemblyQC > PostScaffolding_QC

```Minimap2_rawreadsmap``` > ```Kmer``` > ```Busco``` > ```ChromoMap``` > 
