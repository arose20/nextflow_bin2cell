process VALIDATE_OUTPUTS {
    tag "validate_outputs"

    conda = '/software/cellgen/team298/ar32/envs/visiumhd_env1'
    debug true

    input:
    val result_dirs
    path script_file
    path param_csv_file
    val ids

    output:
    path("validation_report.txt")

    script:
    // Convert the list to a CSV string in Groovy before passing to Bash
    def folders_csv = result_dirs.join(',')

    """
    # Activate Conda
    source "\$(conda info --base)/etc/profile.d/conda.sh"
    conda activate "/software/cellgen/team298/ar32/envs/visiumhd_env1"
    
    echo "[INFO] Validating outputs from all RUN_BIN2CELL runs...]"

    FOLDERS_LIST="${folders_csv}"

    python3 ${script_file} \
        --param_csv ${param_csv_file} \
        --folders \$FOLDERS_LIST \
        --ids ${ids} \
        > validation_report.txt 2>&1

    if [ \$? -ne 0 ]; then
        echo "[ERROR] Validation failed, see validation_report.txt" >&2
        exit 1
    else
        echo "[INFO] Validation passed"
    fi
    """
}
