#!/bin/bash
#SBATCH --job-name=scores
#SBATCH --array=1-22
#SBATCH --cpus-per-task=8
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err

# Get environmental variables
source data/config.env

# Go to the working directory
WORK_DIR="${work_dir}"
cd "$WORK_DIR" || exit 1

# Create results and per_chromosome directories if they do not exist
mkdir -p results
mkdir -p results/per_chromosome

# Get chromosome nubmer
CHR=${SLURM_ARRAY_TASK_ID}

# Set VCF directory and filename prefix
VCF_FILE=$(echo "$vcf_pattern" | sed "s/{chr}/${CHR}/g")

plink2 \
  --vcf "${VCF_FILE}" dosage=DS \
  --score "data/positions/chr${CHR}.positions" 1 2 3 header-read cols=scoresums \
  --out "results/per_chromosome/pgs_chr${CHR}"
