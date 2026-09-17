#!/bin/bash
#SBATCH --job-name=liftover
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Get environmental variables
source data/config.env

# Go to the working directory
WORK_DIR="${work_dir}"
cd "$WORK_DIR" || exit 1

WEIGHTS_FILE="${weights_file}"

# Download hg19ToHg38.over.chain.gz
wget -P data "https://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz"
gunzip -c data/hg19ToHg38.over.chain.gz > data/hg19ToHg38.over.chain
rm data/hg19ToHg38.over.chain.gz

# Run LiftOver in R
srun Rscript R00_liftover.R "$WORK_DIR" "$WEIGHTS_FILE"



