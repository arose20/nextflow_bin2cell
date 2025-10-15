// workflows/test_environment_workflow.nf

include { test_environment } from '../modules/test_environment.nf'

workflow test_environment_workflow {
    take:
    env_home
    default_env_name

    main:
    log.info "[INFO] Running environment accessibility test..."

    env_check_ch = test_environment(env_home, default_env_name)

    emit:
    env_check_done = env_check_ch
}