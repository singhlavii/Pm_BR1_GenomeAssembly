**Analysis of Juicebox output**

To convert juicebox output to a fasta file

For Yahs output:
```
export PATH=$PATH:/g/data/xf3/common/softwares/yahs-1.2.2 
 juicer post -o /scratch/xf3/ls9057/Pmelanocephala/juicebox/reviewed_fasta/Pm_hap1_v1 \ /scratch/xf3/ls9057/Pmelanocephala/juicebox/reviewed_assembly/20260719/Pm_hap1_out_JBAT.review.v1.assembly \ /scratch/xf3/ls9057/Pmelanocephala/yahs_hap1/Pm_hap1_out_JBAT.liftover.agp \ /scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_30Gb_filtered.hap1.fa
```
For 3ddna output:
```
bash /g/data/xf3/ls9057/software/3d-dna/run-asm-pipeline-post-review.sh \
  -r /scratch/xf3/ls9057/Pmelanocephala/juicebox/reviewed_assembly/20260727/Pm_hap12_v1_reorder.0.review_v3.assembly \
  -g 5000 \
  /g/data/xf3/ls9057/Pmelanocephala/juicer_3ddna/Pm_hap12_reorder/references/Pm_hap12_v1_reorder.fa \
  /g/data/xf3/ls9057/Pmelanocephala/juicer_3ddna/Pm_hap12_reorder/aligned/merged_nodups.txt
```
