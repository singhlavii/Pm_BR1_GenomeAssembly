## TE identification using REPETv4 (TEdenovo and PASTEC)

Rita has installed the snakemake workflow here with a readme file here: ```/g/data/xf3/common/snakemake-workflows/REPETv4-snakemake/rita_tutorial.md```

I did each haplotype separately. I initially started running this in the shared workspace but moved to my scratch folder using copyq queue because I had a lot of files in there.

```
OLD=/g/data/xf3/common/snakemake-workflows/REPETv4-snakemake/TEdenovo_snakemake
NEW=/scratch/xf3/ls9057/Pmelanocephala/REPET/TEdenovo_snakemake
cp -rp $OLD/Snakefile $OLD/scripts $OLD/envs $OLD/config $OLD/run_Snakemake.pbs $NEW/

rsync -a --remove-source-files \
  $OLD/results_TEdenovo_PmBR1hap1 $OLD/.snakemake $NEW/
```


In this folder, I have included
1. ```config_hap1.yaml```: includes all paths to input files and parameters.
2. ```run_snakemake.pbs```: I split this script into two with diff settings. This is the first one that runs everything upto filtering.
3. ```run_Snakemake_hap1_MCL.pbs```: Continues from MCL clustering in hugemem queue on NCI.

#### Run Record for Hap1

```
REPET v4.0 TEdenovo (Snakemake), genome PmBR1hap1 (300 Mb subset), run Oct-Nov 2026 on NCI Gadi.
- Clustering: Grouper 22,777 + Recon 6,094 + Piler 1,733 = 30,604 consensus (all_consensus.fa)
- PASTEC banks: Repbase 30.01 (nt + aa), Pfam35.0 + GypsyDB profiles, rRNA_Eukaryota_2020_2021
- PASTEC bug patched: DecisionMakerPerConsensus.py lines 508/542 (sort ties ignore dict fields)
- HMM evidence skipped for batches 63, 1690, 1744 (matcherThreads segfault/memory runaway)
- removeRedundancy disabled (did not finish in 48 h)
- Filtering removed 332 SSRs -> 30,272 consensus
- MCL: inflation 1.5 (code default; config value 4.0 not passed), 2,460 clusters, 221 singletons
- MCL reused completed BLAST; matcher run with -t 24 on hugemem (patched LaunchMCL.py)
```
