#!/bin/bash
#PBS -P xf3
#PBS -q normal
#PBS -l walltime=48:00:00
#PBS -l ncpus=1
#PBS -l mem=2G
#PBS -l storage=scratch/xf3+gdata/xf3
#PBS -l wd
#PBS -j oe
#PBS -m abe

###change settings here###
script_dir=/scratch/xf3/ls9057/Pmelanocephala/blast-snake
conda_snakemake_env=/g/data/xf3/ls9057/venvs/snakemake7
storage=scratch/xf3+gdata/xf3
##########################

source ${script_dir}/gadimod.sh
source /g/data/xf3/ls9057/venvs/snakemake7/bin/activate

set -ueo pipefail
logdir=pbs_log
mkdir -p $logdir
export TMPDIR=${PBS_JOBFS:-$TMPDIR}
TARGET=${TARGET:-all}

QSUB="qsub -q {cluster.queue} -l ncpus={cluster.ncpus} -l ngpus={cluster.ngpus} -l jobfs={cluster.jobfs}"
QSUB="$QSUB -l walltime={cluster.time} -l mem={cluster.mem} -N {cluster.name} -l storage={cluster.storage}"
QSUB="$QSUB -l wd -j oe -o $logdir -P {cluster.project}" 

snakemake																	    \
	-j 500																    \
	--max-jobs-per-second 2													    \
	--cluster-config ${script_dir}/cluster.yaml		\
	--local-cores ${PBS_NCPUS:-1}											    \
	--js ${script_dir}/jobscript.sh			    	\
	--nolock																    \
	--keep-going															    \
	--rerun-incomplete														    \
	--use-envmodules														    \
	--cluster "$QSUB"														    \
	"$TARGET"
