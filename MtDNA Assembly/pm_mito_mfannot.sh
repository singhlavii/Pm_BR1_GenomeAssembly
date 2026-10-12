#!/bin/bash
#PBS -q normal
#PBS -P xf3
#PBS -l ncpus=4
#PBS -l mem=16GB
#PBS -l walltime=06:00:00
#PBS -l wd
#PBS -l storage=scratch/xf3+gdata/xf3
#PBS -j oe
#PBS -m abe
#PBS -M u7406681@anu.edu.au

# Annotate mitogenome(s) with MFannot (BFL-lab), run from its container.
# Get the container once, on a login node (needs internet):
#   module load singularity
#   export SINGULARITY_CACHEDIR=/scratch/xf3/ls9057/.singularity
#   mkdir -p /g/data/xf3/ls9057/containers && cd /g/data/xf3/ls9057/containers
#   singularity pull mfannot.sif docker://nbeck/mfannot
#   singularity exec mfannot.sif mfannot -h

set -xeo pipefail
module load singularity

SIF=/g/data/xf3/ls9057/containers/mfannot.sif
DIR=/scratch/xf3/ls9057/Pmelanocephala/mtdna/assembly
WD=${DIR}/annotation
GCODE=4      # Mold, Protozoan, Coelenterate mitochondrial code (fungi)

# genomes to annotate: name -> FASTA
declare -A GENOMES=(
  [h1tg000047c]=${DIR}/igv/h1tg000047c.mtDNA_candidate.fasta
  [ptg000001c]=${DIR}/igv/ptg000001c.mtDNA_candidate.fasta
)

mkdir -p "$WD"
cd "$WD"

for NAME in "${!GENOMES[@]}"; do
  mkdir -p $NAME
  cd $NAME
  # MFannot takes a "masterfile"; a plain single-sequence FASTA works as input
  cp "${GENOMES[$NAME]}" ${NAME}.fasta

  singularity exec -B /scratch/xf3 "$SIF" \
    mfannot -g $GCODE -l ${NAME}.mfannot.log -o ${NAME}.mfannot.new ${NAME}.fasta

  # quick gene list from the annotated masterfile (lines starting with ';')
  grep '^;' ${NAME}.mfannot.new | grep -E '==>|<==' | awk '{print $2, $3, $4}' | sort -u > ${NAME}.genes.txt || true
  cd "$WD"
done

set +x
for NAME in "${!GENOMES[@]}"; do
  echo "===== $NAME: features found ====="
  cat $WD/$NAME/${NAME}.genes.txt
done
