#!/bin/bash
#SBATCH --job-name=extract
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err


# Get environmental variables
source data/config.env

# Go to the working directory
WORK_DIR="${work_dir}"
cd "$WORK_DIR" || exit 1

# Get the weights data
HG38_WEIGHTS="$(dirname "$weights_file")/hg38_$(basename "$weights_file")"

if [ -f "$HG38_WEIGHTS" ]; then
  WEIGHTS="$HG38_WEIGHTS"
else
  WEIGHTS="$weights_file"
fi

echo "Using weights file: $WEIGHTS"

mkdir -p data/positions
rm -f data/positions/*.positions

for chr in {1..22}
do
  zcat "$WEIGHTS" | \
    awk -v c=$chr '
    NR>1 && $1==c {
        print "chr"$1"_"$2"_"$4"_"$3, $3, $5
    }' OFS="\t" > data/positions/chr${chr}.positions
done