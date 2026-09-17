#!/bin/bash
#SBATCH --job-name=setup

# Create the directories
mkdir -p data
mkdir -p logs
mkdir -p results

# Create confic.env template
CONFIG="data/config.env"

# Create template if it doesn't exist
if [ ! -f "$CONFIG" ]; then
    cat > "$CONFIG" << 'EOF'
###########################################################
# CONFIGURATION FILE
#
# Please fill in the values below
#
# Only edit the text after "=".
###########################################################

# Working directory
work_dir="/path/to/your/working/directory"

# Cohort abbreviation
cohort="cohort_abbreviation_no_spaces_or_slashes"

# Phenotype
phenotype="short_phenotype_name_no_spaces_or_slashes"

# Genotype path and file name, replace chromosome number with {chr}
vcf_pattern="/path/to/your/genetic/data/directory/genotype_chr{chr}.vcf.gz"

# PRS weight file
weights_file="/path/to/your/prs/weights/file"

EOF

    echo "Created $CONFIG"
    echo "Please edit the file and provide your settings."
    exit 1
fi