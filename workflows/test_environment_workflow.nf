// workflows/test_environment_workflow.nf

include { test_environment } from '../modules/test_environment.nf'

workflow test_environment_workflow {

    take:
        env_home
        env_name

    main:
        log.info "[INFO] Running environment accessibility test..."

        // Run your actual process
        done_ch = test_environment(env_home, env_name)
            .map { true }   // convert to a simple "done" signal

    emit:
        done_ch
}
