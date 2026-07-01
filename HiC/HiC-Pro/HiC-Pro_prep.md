**File Prep for Hi-C Pro**

Hi-C Pro needs a specific folder structure for raw reads e.g ```work_dir/HiC_input/Sample_name/HiC_R*.fastq```. To do this , I softlinked the output from TrimGalore.

```
mkdir -p HiC_input/Pm_HiC_sample
ln -sr trimmed_output/Pm_HiC_R1_val_1.fq.gz HiC_input/Pm_HiC_sample/Pm_HiC_sample_R1.fastq.gz
ln -sr trimmed_output/Pm_HiC_R2_val_2.fq.gz HiC_input/Pm_HiC_sample/Pm_HiC_sample_R2.fastq.gz
```

Hi-C pro also needs three other input files. A bowtie2-index file, a chromosome sizes file and a digested bed file. For the digested genome, we need Hi-C Pro's ```digest_genome.py``` file. I git cloned the repository as so to get all the files (but no dependencies).

```
cd /g/data/xf3/ls9057/software
git clone https://github.com/nservant/HiC-Pro.git
cd HiC-Pro
```
Since it dosen't come with dependencies, I had to load all of the software needed as modules in the script. I had to install the other stuff as so:

```
module load python3/3.11.0    
python3 -m venv /g/data/xf3/ls9057/software/hicpro_venv
source /g/data/xf3/ls9057/software/hicpro_venv/bin/activate
pip install numpy scipy
```
Then, I ran ```HiCPro_prep.sh``` provided in the folder. 

**I had initally run both haplotypes seprate but then changed to both haplotypes combined. The code remained the same, except for input files.**
