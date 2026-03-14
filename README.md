# Bin2Cell Nextflow Pipeline

This repository contains a **Nextflow** pipeline for running the `Bin2Cell` workflow, which processes input data according to user-defined parameters, optionally builds containerized environments, and supports testing in isolated environments.  


For more information about `Bin2Cell` see [link](https://github.com/Teichlab/bin2cell)


---

## Table of Contents

- [Features](#features)  
- [Requirements](#requirements)  
- [Installation](#installation)  
- [Pipeline Parameters](#pipeline-parameters)  
- [Workflows](#workflows)  
- [Usage](#usage)  
- [Upcoming](#upcoming)  

---

## Features

- Run `Bin2Cell` processing with **Nextflow DSL2**.      
- Test environment accessibility before running the main workflow.  
- Automatic logging of environment and workflow details.  

---

## Requirements

- **Nextflow** >= 22.x  
- **Java** >= 11  

---

## Installation

Clone this repository:

```bash
git clone https://github.com/arose20/nextflow_bin2cell.git
cd <repo_directory>
```

---

## Pipeline Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `param_csv` | `Input_parameters.csv` | CSV file with input parameters. |
| `outdir` | `results` | Directory to save output results. |
| `logdir` | `logs` | Directory for workflow logs. |
| `id` | `all` | Identifier for the run. |
| `overwrite` | `false` | Overwrite existing results if `true`. |
| `python_script` | `bin2cell_core.py` | Main Python script for Bin2Cell. |
| `test_env_only` | `false` | If `true`, only test environment accessibility. |
| `requirements_file` | `''` | Path to a Python requirements file (optional). |
| `env_name` | `visiumhd_env1` | Name of Conda environment (if using Conda). |
| `env_home` | `/software/cellgen/team298/ar32/envs` | Base path for Conda environments. |

---

## Workflows

The pipeline includes two main workflows:

1. **Test Environment**  
   - File: `workflows/test_environment_workflow.nf`  
   - Description: Checks that the environment is accessible and all dependencies are installed.

2. **Run Bin2Cell**  
   - File: `workflows/run_bin2cell_workflow.nf`  
   - Description: Executes the main Bin2Cell workflow using the input parameters.

---

## Usage

Run the pipeline with default parameters:

```bash
nextflow run main.nf
```

Run with a custom CSV file and output directory:
```bash
nextflow run main.nf \
  --param_csv my_params.csv \
  --outdir my_results
```

Test environment only:
```bash
nextflow run main.nf --test_env_only true
```

---

## Upcoming

- Optionally build containerised environments on demand through shell script
    - Docker
    - Singularity
