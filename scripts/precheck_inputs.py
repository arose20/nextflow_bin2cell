import os
import pandas as pd
import sys
from pathlib import Path
import argparse

def main():
    parser = argparse.ArgumentParser(description="Pre-run check of input files")
    parser.add_argument("--param_csv", required=True)
    parser.add_argument("--id", default="all", help="Identifier(s) to check, comma-separated or 'all'")
    args = parser.parse_args()

    df = pd.read_csv(args.param_csv)

    if args.id == "all":
        ids_to_check = df['Identifier'].tolist()
    else:
        ids_to_check = [x.strip() for x in args.id.split(",")]

    missing = []

    for identifier in ids_to_check:
        row = df[df['Identifier'] == identifier]
        if row.empty:
            missing.append(f"{identifier}: identifier not found in CSV")
            continue
        row = row.iloc[0]

        # Check paths
        paths_to_check = {
            "Bin_outs_path": row['Bin_outs_path'],
            "source_image_path": row['source_image_path'],
            "spaceranger_image_path": row['spaceranger_image_path']
        }

        for name, path in paths_to_check.items():
            if not Path(path).exists():
                missing.append(f"{identifier}: {name} not found at {path}")

    if missing:
        print("[PRECHECK FAILED] Missing input files or directories:")
        for m in missing:
            print(" -", m)
        sys.exit(1)
    else:
        print("[PRECHECK PASSED] All input files and directories exist.")

if __name__ == "__main__":
    main()