include { load_samples } from '../modules/load_samples.nf'
include { run_analysis } from '../modules/run_analysis.nf'
include { validate_outputs } from '../modules/validate_outputs.nf'
include { precheck_inputs } from '../modules/precheck_inputs.nf'

def run_bin2cell(params) {

    // Collect list of identifiers
    def ids_to_run = (params.id == 'all') ?
        Channel.fromPath(params.param_csv)
               .splitCsv(header:true)
               .map{ it.Identifier }
               .toList() :
        Channel.value(params.id)

    // -------------------------------
    // Step 0: Pre-run input check
    // -------------------------------
    precheck_inputs(ids_to_run, params.param_csv)

    // Load CSV and filter identifiers
    samples_ch = load_samples(params.param_csv, params.id)

    // Run analysis per identifier
    run_analysis(samples_ch, params)

    // Run post-run validation
    validate_outputs(ids_to_run, params.param_csv, params.outdir, params.logdir)
}
