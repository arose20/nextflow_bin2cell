def LOAD_SAMPLES(precheck_ch, csv_path_str, selected_id) {
    return precheck_ch
        // wait until precheck finishes, then emit the CSV file path
        .map { _ -> file(csv_path_str) }
        .splitCsv(header:true)
        .map { row -> tuple(row.Identifier, row) }
        .filter { id, row ->
            if (selected_id == 'all') return true
            def ids_to_run = selected_id.split(',')*.trim()
            return ids_to_run.contains(id)
        }
}