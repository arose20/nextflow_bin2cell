#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// ==========================
// Pipeline parameters
// ==========================
params.param_csv        = params.param_csv ?: 'Input_parameters.csv'
params.outdir           = params.outdir ?: 'results'
params.logdir           = params.logdir ?: 'logs'
params.id               = params.id ?: 'all'
params.overwrite        = params.overwrite ?: false
params.python_script    = params.python_script ?: 'bin2cell_core.py'
params.test_env_only    = params.test_env_only ?: false
params.build_containers = params.build_containers ?: false
params.build_mode       = params.build_mode ?: 'clone'       // default to clone
params.temp_env_name    = params.temp_env_name ?: 'visiumhd_temp_build'
params.requirements_file = params.requirements_file ?: ''
params.env_name         = params.env_name ?: 'visiumhd_env1'
params.env_home         = params.env_home ?: '/software/cellgen/team298/ar32/envs'

// ==========================
// Import workflows
// ==========================
include { build_containers_workflow } from './workflows/build_containers_workflow.nf'
include { test_environment_workflow } from './workflows/test_environment_workflow.nf'
include { run_bin2cell_workflow } from './workflows/run_bin2cell_workflow.nf'

// ==========================
// Core workflow
// ==========================
workflow {

    // -------------------------
    // Determine runtime safely based on profile/container
    // -------------------------
    def runtime = ''
    if (workflow.profile == 'singularity') {
        runtime = "Singularity Container"
    } else if (workflow.profile == 'docker') {
        runtime = "Docker Container"
    } else if (workflow.profile == 'conda' || params.build_mode == 'conda') {
        runtime = "Conda (${params.env_name})"
    } else {
        runtime = "Local/Host"
    }

    // -------------------------
    // Log environment info
    // -------------------------
    log.info "==============================================="
    log.info "  🔬 Nextflow Environment Details"
    log.info "-----------------------------------------------"
    log.info "  Profile: ${workflow.profile}"
    log.info "  Runtime: ${runtime}"
    log.info "==============================================="

    // -------------------------
    // Test environment
    // -------------------------
    
    if (params.test_env_only) {
        log.info "\n🔍 Checking environment accessibility..."
        test_environment_workflow(params.env_home, params.env_name)
        return
    }
    
    // -------------------------
    // Run main Bin2Cell workflow
    // -------------------------
    log.info "\n🚀 Running main Bin2Cell workflow..."
    run_bin2cell_workflow()
}
