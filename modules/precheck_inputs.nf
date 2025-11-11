process PRECHECK_INPUTS {
    tag "precheck_inputs"

    conda true
    conda = '/software/cellgen/team298/ar32/envs/visiumhd_env1'
    debug true

    input:
    val ids
    path param_csv_file
    path script_file

    output:
    path "precheck_output.txt"

    script:
    """
    # Activate Conda environment
    source "\$(conda info --base)/etc/profile.d/conda.sh"
    conda activate "/software/cellgen/team298/ar32/envs/visiumhd_env1"

    python3 ${script_file} --param_csv ${param_csv_file} --id ${ids} > precheck_output.txt 2>&1

    # Check exit status
    if [ \$? -ne 0 ]; then
        echo "[ERROR] precheck_inputs.py failed, see precheck_output.txt" >&2
        exit 1
    fi
    """
}
