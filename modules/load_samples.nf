// Module: load_samples.nf
// Reads CSV and filters based on user selection
// Returns channel of tuples: (Identifier, row)

def load_samples(file_csv, selected_id) {

    Channel
        .fromPath(file_csv)
        .splitCsv(header:true)
        .map { row -> tuple(row.Identifier, row) }
        .filter { id, row ->
            if (selected_id == 'all') return true
            def ids_to_run = selected_id.split(',')*.trim()
            return ids_to_run.contains(id)
        }
        .set { samples }
    
    return samples
}
