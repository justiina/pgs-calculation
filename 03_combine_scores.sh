#!/bin/bash
#SBATCH --job-name=combine_scores
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Get environmental variables
source data/config.env

# Go to the working directory
WORK_DIR="${work_dir}"
cd "$WORK_DIR" || exit 1

COHORT="${cohort}"
PHENO="${phenotype}"

srun Rscript R03_combine_scores.R "$WORK_DIR" "$COHORT" "$PHENO"