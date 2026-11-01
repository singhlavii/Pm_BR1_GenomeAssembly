# HiC Contacts with HiC-Pro #

This workflow/script is for the assembly v20260829. 

## 1. HiC-Pro Prep

Input files were prepared using ```HiCPro_prep_hap12_v2_20260829.sh```. The parameters set are included in ```config_hap12_v2_20260829.txt```.

## 2. HiC-Pro Mapping

I ran HiC-Pro mapping with ```hicpro_hap12_v2_full_20261013.sh```. This ended with the error that the allValidPairs file was not created. This seems to be an error with the
version (2.10.0) that I was running. So I just created the file myself using:
```
sort -k2,2 -k3,3n -k5,5 -k6,6n \
    hic_results/data/Pm_HiC_sample/*.validPairs | \
    uniq > hic_results/data/Pm_HiC_sample/Pm_HiC_sample_allValidPairs
```

Then, I ran ```hicpro_hap12_v2_maps_20261015.sh```. 

### 3. Table Output

To get a table summarizing the contacts (Similar to Rita's paper), I used the code below:
```
# ── paths ──────────────────────────────────────────────────────────────
HICDIR=/scratch/xf3/ls9057/Pmelanocephala/HiC
RUN=hicpro_output_hap12_v2_20261013          # name of the HiC-Pro output dir
SAMPLE=Pm_HiC_sample                         # sample name used inside HiC-Pro
ALLVP=$HICDIR/$RUN/hic_results/data/$SAMPLE/${SAMPLE}_allValidPairs
# ───────────────────────────────────────────────────────────────────────

ls -lh $ALLVP   # sanity check — confirm file exists before running awk

awk '{
    c1=$2; c2=$5
    h1 = (c1 ~ /_hap1$/)
    h2 = (c2 ~ /_hap1$/)

    if (h1 != h2) {
        cross++
    } else if (c1 == c2) {
        if (h1) hap1_cis++; else hap2_cis++
    } else {
        if (h1) hap1_trans++; else hap2_trans++
    }
    total++
} END {
    within = hap1_cis + hap2_cis + hap1_trans + hap2_trans
    printf "Types of Hi-C contacts\tCounts\n"
    printf "Total Hi-C links\t%d\n", total
    printf "Within-haplotype links\t%d (%.1f%%)\n", within, within*100/total
    printf " cis-chromosome\n"
    printf "  Haplotype 1\t%d (%.1f%%)\n", hap1_cis,   hap1_cis*100/total
    printf "  Haplotype 2\t%d (%.1f%%)\n", hap2_cis,   hap2_cis*100/total
    printf " trans-chromosome\n"
    printf "  Haplotype 1\t%d (%.1f%%)\n", hap1_trans, hap1_trans*100/total
    printf "  Haplotype 2\t%d (%.1f%%)\n", hap2_trans, hap2_trans*100/total
    printf "Cross-haplotype links\t%d (%.1f%%)\n", cross, cross*100/total
}' $ALLVP
```
