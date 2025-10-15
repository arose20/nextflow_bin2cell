// Module: run_analysis.nf
// Runs the Python script per identifier

process run_analysis {

    tag "$id"

    publishDir "${params.outdir}/${id}", mode: 'copy'

    input:
    tuple val(id), val(row)

    output:
    file("${id}_post_b2c.h5ad") into results

    // Use conda environment defined in profiles.config
    conda true

    script:
    """
    OUTPUT_FILE=${params.outdir}/${id}/${id}_post_b2c.h5ad

    # Skip if output exists and overwrite is false
    if [ -f "\$OUTPUT_FILE" ] && [ "${params.overwrite}" = "false" ]; then
        echo "[INFO] Output already exists for ${id}, skipping (overwrite=false)"
        exit 0
    fi

    mkdir -p ${params.outdir}/${id}
    mkdir -p ${params.logdir}

    python3 scripts/${params.python_script} \
        --Identifier "${row.Identifier}" \
        --mpp ${row.mpp} \
        --buffer ${row.buffer} \
        --prob_thresh_he ${row.prob_thresh_he} \
        --prob_thresh_gex ${row.prob_thresh_gex} \
        --Bin_outs_path "${row.Bin_outs_path}" \
        --source_image_path "${row.source_image_path}" \
        --spaceranger_image_path "${row.spaceranger_image_path}" \
        --outdir ${params.outdir}/${id} \
        --overwrite ${params.overwrite} \
        > ${params.logdir}/${id}.log 2>&1
    """
}

// Function wrapper to call this module from main.nf
def run_analysis(channel, params) {
    run_analysis(channel)
}
