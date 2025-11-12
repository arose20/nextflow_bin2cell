process RUN_BIN2CELL {
    tag "run_bin2cell"

    debug true

    input:
    tuple val(id), val(row)
    path script_file

    // Publish the main results folder (stardist + final h5ad)
    publishDir "${projectDir}/results", pattern: "${id}_work", mode: 'move', overwrite: false

    // Publish log file separately in logs folder
    publishDir "${projectDir}/logs", pattern: "${id}.log", mode: 'move', overwrite: false

    output:
    tuple(path("${id}_work"), path("${id}.log"))

    script:
    """
    # Path to final expected output in project results
    FINAL_OUTPUT="${projectDir}/results/${id}_work/${id}_post_b2c.h5ad"

    # Temporary work folder for this run
    WORK_DIR="${id}_work"
    mkdir -p \$WORK_DIR

    # Log file path
    LOG_FILE="${id}.log"

    if [ ! -f "\$FINAL_OUTPUT" ] || [ "${params.overwrite}" = "true" ]; then
        echo "[INFO] Running bin2cell for ${id}..."

        # Run main Python script with per-row parameters
        python3 ${script_file} \
            --Identifier "${row.Identifier}" \
            --mpp ${row.mpp} \
            --buffer ${row.buffer} \
            --prob_thresh_he ${row.prob_thresh_he} \
            --prob_thresh_gex ${row.prob_thresh_gex} \
            --Bin_outs_path "${row.Bin_outs_path}" \
            --source_image_path "${row.source_image_path}" \
            --spaceranger_image_path "${row.spaceranger_image_path}" \
            --outdir \$WORK_DIR \
            > \$LOG_FILE 2>&1

        if [ \$? -ne 0 ]; then
            echo "[ERROR] bin2cell_core.py failed, see \$LOG_FILE" >&2
            exit 1
        fi
    else
        echo "[INFO] Skipping ${id}: final output exists and overwrite=false"

        # Copy existing results into work folder so publishDir moves it correctly
        mkdir -p \$WORK_DIR
        #cp -r "${projectDir}/results/${id}_work/"* \$WORK_DIR/

        # Create a placeholder log if missing so validation works
        if [ ! -f "\$LOG_FILE" ]; then
            echo "[INFO] Skipped ${id}: final output exists, no new run executed on \$(date)" > \$LOG_FILE
        fi
    fi
    """
}
