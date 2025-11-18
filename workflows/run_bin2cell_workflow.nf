nextflow.enable.dsl = 2

include { PRECHECK_INPUTS } from '../modules/precheck_inputs.nf'
include { LOAD_SAMPLES } from '../modules/load_samples.nf'
include { RUN_BIN2CELL } from '../modules/run_core_bin2cell.nf'
include { VALIDATE_OUTPUTS } from '../modules/validate_outputs.nf'

workflow run_bin2cell_workflow {

    main:        
        println "[INFO] Parameters CSV: ${params.param_csv}"
        println "[INFO] Selected ID(s): ${params.id}"
        println "[INFO] Output directory: ${params.outdir}"

        precheck_script      = file("scripts/precheck_inputs.py")
        param_csv_file       = file(params.param_csv)
        core_bin2cell_script = file("scripts/bin2cell_core.py")
        validate_script      = file("scripts/validate_outputs.py")
        
        // Step 1: precheck for all rows
        precheck_ch = PRECHECK_INPUTS(params.id, param_csv_file, precheck_script)

        
        //Step 2: load samples after precheck
        samples_ch = LOAD_SAMPLES(precheck_ch, param_csv_file, params.id)

        //Step 3: run bin2cell with tuples (id,row)
        results_ch = RUN_BIN2CELL(samples_ch, core_bin2cell_script)
        
        
        //Step 4: Validate outputs
        val_ch = VALIDATE_OUTPUTS(
            results_ch
                .map { r, l -> file("${projectDir}/results/${r.getName()}") }   // published folder paths
                .collect(),
            file("scripts/validate_outputs.py"),
            param_csv_file,
            params.id
        )
        


    emit:
        val_ch
}
