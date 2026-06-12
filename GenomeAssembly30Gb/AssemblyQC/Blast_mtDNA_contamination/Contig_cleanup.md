# MtDNA and Contamination cleanup of Contig level Assembly

I refered to Rita's github ```(Pst104EGenomeAnalysis/genome_assembly/blast_contaminant_mtDNA/assembly_cleanup.md)``` She has explained steps so I'll just summarize my codes here.


```
cat *.blast > ../all.blast
```


#### MtDNA

Get list of mtDNA matches here

```
grep mitochon all.blast > mtDNA.blast
cut -f1 mtDNA.blast | sort | uniq > mtDNA_contigs.txt
wc -l mtDNA_contigs.txt
```

I had a lot of contigs matching so I looked at qcov and length. Some of the larger contigs (>1Mb) had some chunks that had hits but their qcov = 0. These were likely NUMTs or some shared stuff. I looked at coverage plots which I generated using KaryoplotR and coverage looked okay. Because of low qcov I did not consider these as mtDNA. The smaller contigs (<1Mb) that had mito hits with high qcov also had high coverage >100X, so I felt confident that these were likely mtDNA.

```
awk -F'\t' '$5 > 1' mtDNA.blast | cut -f1 | sort | uniq > mtDNA_contigs_qcov1.txt
```

I then saved the mtDNA contigs separatly so I could assemble mtgenome later

```
module load seqtk
seqtk subseq Pm_ONT_30Gb_trial.hap12.asm.fa mtDNA_contigs_qcov1.txt > mtDNA.fasta
```

I removed mtDNA contigs 

```
module load bbmap
filterbyname.sh in=Pm_ONT_30Gb_trial.hap12.asm.fa out=Pm_30Gb_mtDNArm.hap12.asm.fa names=mtDNA_contigs_qcov1.txt
```


### Contamination

I checked all species names ```cut -f12 all.blast | sort | uniq | less```

There were several names so I reverse searched using ``` grep "Tetranychus urticae" all.blast``` too see what they looked like. I selected contigs that had hits with >10 qcov and low read coverage (<10x) as contaminants. I filtered them using 

```
module load bbmap
filterbyname.sh in=Pm_30Gb_mtDNArm.hap12.asm.fa out=Pm_30Gb_filtered.hap12.asm.fa names=species_contamn.txt
```

There were another two contigs that matched to Puccinia rDNA but they had >10 coverage so I removed those too. They are listed in ```lowcov_contigs.txt```


