import os
from pathlib import Path
import pandas as pd
import sys

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Validate bin2cell outputs")
    parser.add_argument("--param_csv", required=True)
    parser.add_argument("--outdir", required=True)
    parser.add_argument("--logdir", required=True)
    parser.add_argument("--id", default="all", help="Single or comma-separated identifiers to check, or 'all'")
    args = parser.parse_args()

    # Read identifiers
    df = pd.read_csv(args.param_csv)
    if args.id == 'all':
        ids_to_check = df['Identifier'].tolist()
    else:
        ids_to_check = [x.strip() for x in args.id.split(',')]

    missing = []

    for identifier in ids_to_check:
        # Folder for this identifier
        id_folder = Path(args.outdir) / identifier
        if not id_folder.exists():
            missing.append(f"{identifier}: results folder missing")
            continue

        # Stardist folder
        stardist_folder = id_folder / "stardist"
        if not stardist_folder.exists():
            missing.append(f"{identifier}: stardist folder missing")

        # Log file
        log_file = Path(args.logdir) / f"{identifier}.log"
        if not log_file.exists():
            missing.append(f"{identifier}: log file missing")

        # Expected stardist outputs
        expected_stardist_files = ['he.tiff', 'he.npz', 'gex.tiff', 'gex.npz']
        for f in expected_stardist_files:
            if not (stardist_folder / f).exists():
                missing.append(f"{identifier}: missing {f} in stardist folder")

        # Final AnnData object
        anndata_file = id_folder / f"{identifier}_post_b2c.h5ad"
        if not anndata_file.exists():
            missing.append(f"{identifier}: final AnnData object missing")

    if missing:
        print("[VALIDATION FAILED] Missing outputs:")
        for m in missing:
            print(" -", m)
        sys.exit(1)
    else:
        print("[VALIDATION PASSED] All expected outputs are present.")

if __name__ == "__main__":
    main()