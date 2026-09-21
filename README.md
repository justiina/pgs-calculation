# PGS calculation pipeline

## Overview

This pipeline provides a reproducible workflow for calculating polygenic scores (PGS) from genotype data using externally derived variant weight files. Before running the pipeline, users should execute the setup script, which creates a `data/config.env` file containing the project-specific parameters required by the pipeline. These include the working directory, cohort and phenotype identifiers, the genotype file location and naming pattern, and the path to the PGS weight file. 

Once configured, the pipeline can be executed using the supplied shell and R scripts. It is designed to address common challenges in genomic analyses, including differences in genome builds, chromosome-wise processing of large-scale genetic datasets, and aggregation of chromosome-level results into participant-level scores.

### Some notes:
- At present, the pipeline supports genotype data in VCF format. Users requiring other file formats can adapt the scripts as needed. The default workflow assumes that VCF files are split by chromosome, with one file per chromosome. If genotype data are stored in a different format or organisation, users can adapt the 01b_calculate_scores_by_chr.sh script to match their file structure and naming conventions.

- For studies where the variant weight file is based on the hg19 genome build and the target genotype data are aligned to hg38, an optional liftover step is available. [Liftover](https://github.com/justiina/pgs-calculation/blob/main/00b_liftover.sh) script downloads and extracts the hg19ToHg38 chain file from [UCSC Chain Files](https://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/) and performs coordinate conversion using the liftOver() function from the [rtracklayer](https://bioconductor.org/packages/release/bioc/html/rtracklayer.html) R package. The script can be readily modified to support other genome build conversions when required.

## Workflow
- **Input**: Genotype data and a PGS weight file containing variant effect estimates.
- **Output**: Individual-level polygenic scores and log file containing the number of available and unavailable SNPs.

### 1) Preprocessing
During preprocessing, the pipeline initialises the analysis environment and, when necessary, converts variant build between genome assemblies using a liftover procedure. This ensures that the genomic positions in the PGS weight file are aligned with those used in the target genotype data.

#### Steps
1. Configure the analysis environment by running [00a_setup.sh](https://github.com/justiina/pgs-calculation/blob/main/00a_setup.sh).
2. Add following information to the just created data/config.env file: working directory, cohort abbreviation, phenotype name, genotype data path and file name and PRS weight file.
3. Harmonise genome builds through coordinate liftover when required by [00b_liftover.sh](https://github.com/justiina/pgs-calculation/blob/main/00b_liftover.sh).

### 2) Score Calculation
In the score calculation step, variants contained in the weight file are extracted by chromosome. Polygenic scores are then calculated independently for each chromosome, enabling efficient parallel processing on high-performance computing environments.

#### Steps
1. Extract chromosome-specific variants from the weight file by [01a_extract_snps_by_chr.sh](https://github.com/justiina/pgs-calculation/blob/main/01a_extract_snps_by_chr.sh).
2. Calculate chromosome-level polygenic scores by [01b_calculate_scores_by_chr.sh](https://github.com/justiina/pgs-calculation/blob/main/01b_calculate_scores_by_chr.sh).

### 3) Results Aggregation
Finally, chromosome-specific outputs are combined to generate participant-level polygenic scores. The resulting outputs include the final PGS values together with supporting log files containing the number of available and unavailable SNPs utilised when calculating the scores.

#### Steps
1. Summarise scoring logs by [02_combine_log_info.sh](https://github.com/justiina/pgs-calculation/blob/main/02_combine_log_info.sh).
2. Merge chromosome-level scores into final participant-level PGS results by [R03_combine_scores.R](https://github.com/justiina/pgs-calculation/blob/main/R03_combine_scores.R).

## Flowchart
```mermaid
flowchart TD

subgraph group_preprocess["Preprocessing"]
  node_setup["Pipeline Setup<br/>[00a_setup.sh]"]
  node_liftover["Build Liftover<br/>[00b_liftover.sh]"]
  node_liftover_r["Liftover Logic<br/>[R00_liftover.R]"]
end

subgraph group_scoring["Score Calculation"]
  node_snp_extract["SNP Weights Per Chromosome<br/>[01a_extract_snps_by_chr.sh]"]
  node_score_calc["Chromosome Scoring<br/>[01b_calculate_scores_by_chr.sh]"]
end

subgraph group_aggregation["Results Aggregation"]
  node_log_combine["Log Combination<br/>[02_combine_log_info.sh]"]
  node_score_combine["Score Combination<br/>[03_combine_scores.sh]"]
  node_score_combine_r["Score Merge Logic<br/>[R03_combine_scores.R]"]
end

node_analyst(("Analyst"))
node_input_data["Input Data"]
node_pgs_result["PGS Results"]

node_analyst -->|"starts"| node_setup
node_input_data -->|"provides"| node_setup
node_setup -->|"prepares"| node_liftover
node_liftover -->|"runs"| node_liftover_r
node_liftover -->|"passes liftovered weights"| node_snp_extract
node_snp_extract -->|"passes SNPs"| node_score_calc
node_input_data -->|"provides weights"| node_snp_extract
node_score_calc -->|"passes logs"| node_log_combine
node_score_calc -->|"passes scores"| node_score_combine
node_score_combine -->|"runs"| node_score_combine_r
node_score_combine -->|"writes PGS"| node_pgs_result

click node_setup "https://github.com/justiina/pgs-calculation/blob/main/00a_setup.sh"
click node_liftover "https://github.com/justiina/pgs-calculation/blob/main/00b_liftover.sh"
click node_liftover_r "https://github.com/justiina/pgs-calculation/blob/main/R00_liftover.R"
click node_snp_extract "https://github.com/justiina/pgs-calculation/blob/main/01a_extract_snps_by_chr.sh"
click node_score_calc "https://github.com/justiina/pgs-calculation/blob/main/01b_calculate_scores_by_chr.sh"
click node_log_combine "https://github.com/justiina/pgs-calculation/blob/main/02_combine_log_info.sh"
click node_score_combine "https://github.com/justiina/pgs-calculation/blob/main/03_combine_scores.sh"
click node_score_combine_r "https://github.com/justiina/pgs-calculation/blob/main/R03_combine_scores.R"

classDef toneNeutral fill:#f8fafc,stroke:#334155,stroke-width:1.5px,color:#0f172a
classDef toneBlue fill:#dbeafe,stroke:#2563eb,stroke-width:1.5px,color:#172554
classDef toneAmber fill:#fef3c7,stroke:#d97706,stroke-width:1.5px,color:#78350f
classDef toneMint fill:#dcfce7,stroke:#16a34a,stroke-width:1.5px,color:#14532d
classDef toneRose fill:#ffe4e6,stroke:#e11d48,stroke-width:1.5px,color:#881337
classDef toneIndigo fill:#e0e7ff,stroke:#4f46e5,stroke-width:1.5px,color:#312e81
classDef toneTeal fill:#ccfbf1,stroke:#0f766e,stroke-width:1.5px,color:#134e4a
class node_setup,node_liftover,node_liftover_r toneBlue
class node_snp_extract,node_score_calc toneAmber
class node_log_combine,node_score_combine,node_score_combine_r toneMint
class node_analyst,node_input_data,node_pgs_result toneIndigo
```