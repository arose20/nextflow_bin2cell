#!/usr/bin/env nextflow

// ==========================
// Pipeline parameters
// ==========================
params.param_csv      = file(params.param_csv ?: 'Input_parameters.csv')
params.outdir         = file(params.outdir ?: 'results')
params.logdir         = file(params.logdir ?: 'logs')
params.id             = params.id ?: 'all'
params.overwrite      = params.overwrite ?: false
params.python_script  = params.python_script ?: 'bin2cell_core.py'
params.test_env_only  = params.test_env_only ?: false

// ==========================
// Import workflows & modules
// ==========================
include { test_environment } from './modules/test_environment.nf'
include { run_bin2cell } from './workflows/run_bin2cell.nf'

// ==========================
// Detect environment
// ==========================

// Default env base (matches your conf/profiles.config)
def env_home = System.getenv('NXF_CONDA_HOME') ?: '/software/cellgen/team298/ar32/envs'

// Get environment name from NEXTFLOW_CONDA_ENV if user sets it
def env_name = System.getenv('NEXTFLOW_CONDA_ENV')
if (!env_name?.trim()) {
    env_name = 'visiumhd_env1'   // fallback to default
}

log.info ""
log.info "==============================================="
log.info "  🔬 Nextflow Conda Environment Test"
log.info "-----------------------------------------------"
log.info "  Base: ${env_home}"
log.info "  Env:  ${env_name}"
log.info "==============================================="

// ==========================
// Run workflow
// ==========================
workflow {

    log.info "\n🔍 [STEP 1] Checking environment accessibility..."
    def env_check = test_environment(env_home, env_name)

    if (params.test_env_only) {
        log.info "\n✅ Environment test completed successfully (--test_env_only true). Exiting."
        return
    }

    env_check.env_check_done.subscribe {
        log.info "\n✅ Environment accessible — proceeding to analysis."
    }

    log.info "\n🚀 [STEP 2] Running main Bin2Cell workflow..."
    run_bin2cell(params)
}
