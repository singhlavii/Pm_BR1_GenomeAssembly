I used Rita's blast snakemake pipeline here. Instructions were shared by her.

First I copied her blast-snake folder which contains all files to my scratch from here. 

```/g/data/xf3/ht5438/project/pangenome_pst/blast/blast-snake```

First, she recommends splitting your genome into smaller chunks, maximum 1Mbp per file. Her python script for this is in the folder called split_genome.py. Run

```python split_genome.py <input.fasta> <output_dir>```

Now you are ready to run blast. Edit the ```config.yaml``` file with your specifiic directories. 

Then edit ```submit_on_node.sh``` and input your settings. The snakemake pipeline relies on snakemake v7 but the version installed in shared conda env is v8 (which dosen't work) so i installed my own conda env here

```/g/data/xf3/ls9057/venvs/snakemake7```

I did this with

```module load python3/3.11.7
python -m venv /scratch/xf3/ls9057/venvs/snakemake7
source /scratch/xf3/ls9057/venvs/snakemake7/bin/activate
pip install snakemake==7.32.4
snakemake --version```

