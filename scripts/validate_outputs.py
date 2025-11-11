#!/usr/bin/env python3
import sys
from pathlib import Path
import pandas as pd
import argparse

def main():
    parser = argparse.ArgumentParser(description="Validate bin2cell outputs")
    parser.add_argument("--param_csv", required=True, help="Parameter CSV used for the run")
    parser.add_argument("--folders", required=True, nargs="+", help="Output folders to check")
    parser.add_argument("--ids", default="all", help="Comma-separated IDs or 'all'")
    args = parser.parse_args()

    # Load parameters to determine which IDs to check
    df = pd.read_csv(args.param_csv)
    ids_to_check = df['Identifier'].tolist() if args.ids == 'all' else [x.strip() for x in args.ids.split(',')]

    # Convert folder paths to Path objects
    folder_paths = [Path(f.strip()) for f in args.folders[0].split(',')]

    print(f"[DEBUG] Folder paths passed to validation script:")
    for f in folder_paths:
        print(f"  {f.resolve()}")  # absolute path

    missing = []

    for id_ in ids_to_check:
        # Find the folder with the correct _work suffix
        folder = next((f for f in folder_paths if f.name == f"{id_}_work"), None)
        print(f"[DEBUG] Checking ID '{id_}' => folder: {folder.resolve() if folder else 'None'}")

        if folder is None or not folder.exists():
            missing.append(f"{id_}: results folder missing")
            continue

        # Check stardist subfolder
        stardist_folder = folder / "stardist"
        if not stardist_folder.exists():
            missing.append(f"{id_}: stardist folder missing")
        else:
            for f_name in ['he.tiff', 'he.npz', 'gex.tiff', 'gex.npz']:
                if not (stardist_folder / f_name).exists():
                    missing.append(f"{id_}: missing {f_name} in stardist folder")

        # Check final AnnData
        h5ad_file = folder / f"{id_}_post_b2c.h5ad"
        if not h5ad_file.exists():
            missing.append(f"{id_}: final AnnData object missing")

    if missing:
        print("[VALIDATION FAILED] Missing outputs:")
        for m in missing:
            print(f" - {m}")
        sys.exit(1)
    else:
        print("[VALIDATION PASSED] All expected outputs are present.")

if __name__ == "__main__":
    main()
