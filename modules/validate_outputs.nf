// Module: validate_outputs.nf
// Checks that all expected outputs for the identifiers exist

process VALIDATE_OUTPUTS {
    tag "validate_outputs"

    input:
    val ids        // list of identifiers to check
    val param_csv  // Input_parameters.csv
    val outdir     // output directory
    val logdir     // log directory

    output:
    file("validation_report.txt")

    script:
    """
    python3 scripts/validate_outputs.py \
        --param_csv ${param_csv} \
        --outdir ${outdir} \
        --logdir ${logdir} \
        --id ${ids} \
        > validation_report.txt
    """
}

// Wrapper function for workflow
def validate_outputs(ids, param_csv, outdir, logdir) {
    VALIDATE_OUTPUTS(ids, param_csv, outdir, logdir)
}
