# nextflow_bin2cell
nextflow pipeline for running bin2cell











# setup
conda create -n nextflow_AR -c bioconda -c conda-forge nextflow
conda activate nextflow_AR
nextflow -version
conda install conda-forge::docker


# Create main folders (optional, but standard)
mkdir -p workflows
mkdir -p bin
mkdir -p conf

# Create a minimal nextflow.config
touch nextflow.config

# Add a sample pipeline file
touch main.nf



# running pipeline

nextflow run main.nf -profile conda --test_env_only true

nextflow run main.nf -profile conda --id LC03


export NEXTFLOW_CONDA_ENV="my_custom_env"
nextflow run main.nf -profile conda --id LC05
