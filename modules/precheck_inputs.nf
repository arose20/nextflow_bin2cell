// Module: precheck_inputs.nf
// Verifies that all files and directories listed in Input_parameters.csv exist

process PRECHECK_INPUTS {
    tag "precheck_inputs"

    input:
    val ids        // list of identifiers to check
    val param_csv  // Input_parameters.csv

    output:
    val "ok" into precheck_done  // dummy output to trigger workflow continuation

    script:
    """
    python3 scripts/precheck_inputs.py \
        --param_csv ${param_csv} \
        --id ${ids}
    """
}

// Wrapper function
def precheck_inputs(ids, param_csv) {
    PRECHECK_INPUTS(ids, param_csv)
}
