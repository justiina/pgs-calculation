#!/bin/bash
#SBATCH --job-name=combine_logs
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# Get environmental variables
source data/config.env

# Go to the working directory
WORK_DIR="${work_dir}"
cd "$WORK_DIR" || exit 1

COHORT="${cohort}"
PHENO="${phenotype}"

echo -e "CHR\tUSED\tSKIPPED\tTOTAL\tUSED_REL\tSKIPPED_REL" > "results/${COHORT}_${PHENO}_pgs_variant_summary.tsv"

for log in results/per_chromosome/pgs_chr*.log; do
    chr=$(basename "$log" | sed -E 's/pgs_chr([0-9XYM]+).log/\1/')

    used=$(grep -oP '(?<=--score: )\d+(?= variants processed)' "$log")
    skipped=$(grep -oP '\d+(?= --score file entries were skipped)' "$log")

    skipped=${skipped:-0}
    total=$((used + skipped))

    used_rel=$(awk -v u="$used" -v t="$total" 'BEGIN {printf "%.4f", u/t}')
    skipped_rel=$(awk -v s="$skipped" -v t="$total" 'BEGIN {printf "%.4f", s/t}')

    echo -e "${chr}\t${used}\t${skipped}\t${total}\t${used_rel}\t${skipped_rel}" >> "results/${COHORT}_${PHENO}_pgs_variant_summary.tsv"
done