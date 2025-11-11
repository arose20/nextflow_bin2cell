#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { BUILD_CONTAINERS } from '../modules/build_containers.nf'

workflow build_containers_workflow {

    if (!params.build_containers) {
        log.info "⚙️ Skipping container build"
        return
    }

    def mode = params.build_mode
    def source = params.env_name
    def temp_env = params.temp_env_name
    def req_file = params.requirements_file

    if (mode == 'conda') {
        if (!source) error "Conda mode requires a YAML file"
        BUILD_CONTAINERS(source, temp_env, 'conda')

    } else if (mode == 'pip') {
        if (!req_file) error "Pip mode requires a requirements file"
        BUILD_CONTAINERS(req_file, temp_env, 'pip')

    } else if (mode == 'clone') {
        if (!source) source = 'visiumhd_env1' // safety fallback
        BUILD_CONTAINERS(source, temp_env, 'clone')

    } else {
        error "Invalid build_mode: ${mode}"
    }
}

