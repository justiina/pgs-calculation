# PGS calculation pipeline

## Overview

This pipeline provides a reproducible workflow for calculating polygenic scores (PGS) from genotype data and externally derived variant weight files. It is designed to handle common challenges encountered in genomic studies, including differences in genome builds, chromosome-wise processing of large genetic datasets, and aggregation of results across chromosomes into participant-level scores. The pipeline is implemented using shell and R scripts and is intended to be flexible across different cohorts and computing environments. By separating preprocessing, scoring, and aggregation into modular components, it enables users to adapt individual steps while maintaining a standardized and reproducible analytical workflow.

## Workflow
- **Input**: Genotype data and a PGS weight file containing variant effect estimates.
- **Output**: Individual-level polygenic scores and log file containing the number of available and unavailable SNPs.

### 1) Preprocessing
During preprocessing, the pipeline initialises the analysis environment and, when necessary, converts variant build between genome assemblies using a liftover procedure. This ensures that the genomic positions in the PGS weight file are aligned with those used in the target genotype data.

<div style="background-color: #f5f3ff; color: #5b21b6; padding: 15px; border-left: 5px solid #8b5cf6; border-radius: 4px;">
  <strong>Steps</strong>
  <ul style="list-style-type: none; padding-left: 0; margin-top: 8px;">
    <li>1.1 Configure the analysis environment.</li>
    <li>1.2 Add following information to the config.env file: working directory, cohort abbreviation, phenotype name, genotype data path and file name and PRS weight file.</li>
    <li>1.3 Harmonise genome builds through coordinate liftover when required.</li>
  </ul>
</div>

### 2) Score Calculation
In the score calculation step, variants contained in the weight file are extracted by chromosome. Polygenic scores are then calculated independently for each chromosome, enabling efficient parallel processing on high-performance computing environments.

<div style="background-color: #f5f3ff; color: #5b21b6; padding: 15px; border-left: 5px solid #8b5cf6; border-radius: 4px;">
  <strong>Steps</strong>
  <ul style="list-style-type: none; padding-left: 0; margin-top: 8px;">
    <li>2.1 Extract chromosome-specific variants from the weight file.</li>
    <li>2.2 Calculate chromosome-level polygenic scores in parallel.</li>
  </ul>
</div>

### 3) Results Aggregation
Finally, chromosome-specific outputs are combined to generate participant-level polygenic scores. Quality-control metrics and log files produced during the scoring process are aggregated into summary reports, providing transparency regarding variant matching and score calculation performance. The resulting outputs include the final PGS values together with supporting metadata that can be used for downstream statistical analyses.

<div style="background-color: #f5f3ff; color: #5b21b6; padding: 15px; border-left: 5px solid #8b5cf6; border-radius: 4px;">
  <strong>Steps</strong>
  <ul style="list-style-type: none; padding-left: 0; margin-top: 8px;">
    <li>3.1 Summarise scoring logs and quality metrics.</li>
    <li>3.2 Merge chromosome-level scores into final participant-level PGS results.</li>
  </ul>
</div>

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