# ==============================================
# Step 0: Import required packages
# ==============================================
import os
import numpy as np
import pandas as pd
import scanpy as sc
import bin2cell as b2c
from scipy.sparse import issparse
import argparse
from pathlib import Path
from PIL import Image
Image.MAX_IMAGE_PIXELS = None
os.environ["OPENCV_IO_MAX_IMAGE_PIXELS"] = str(2**40)
import cv2

def main():
    # ==============================================
    # Step 1: Define command-line arguments
    # ==============================================
    parser = argparse.ArgumentParser(description="Run analysis for VisiumHD samples")

    parser.add_argument("--Identifier", required=True)
    parser.add_argument("--mpp", type=float, required=True)
    parser.add_argument("--buffer", type=int, required=True)
    parser.add_argument("--prob_thresh_he", type=float, required=True)
    parser.add_argument("--prob_thresh_gex", type=float, required=True)
    parser.add_argument("--Bin_outs_path", required=True)
    parser.add_argument("--source_image_path", required=True)
    parser.add_argument("--spaceranger_image_path", required=True)
    parser.add_argument("--outdir", required=True)

    args = parser.parse_args()

    # ==============================================
    # Step 2: Create output directory and stardist subdirectory
    # ==============================================
    OUTDIR = Path(args.outdir)
    OUTDIR.mkdir(parents=True, exist_ok=True)

    STARDIST_DIR = OUTDIR / "stardist"
    STARDIST_DIR.mkdir(parents=True, exist_ok=True)

    # ==============================================
    # Step 3: Bin2cell workflow
    # ==============================================

    print(f"[INFO] Running bin2cell pipeline for {args.Identifier}")

    # Load data and add identifier
    adata = b2c.read_visium(
        path=args.Bin_outs_path,
        source_image_path=args.source_image_path,
        spaceranger_image_path=args.spaceranger_image_path
    )
    adata.var_names_make_unique()

    adata.obs['Identifier'] = args.Identifier

    # perform basic QC
    sc.pp.filter_genes(adata, min_cells=3)
    sc.pp.filter_cells(adata, min_counts=1)

    # construct new HE image
    he_tiff_path = str(STARDIST_DIR / 'he.tiff')
    b2c.scaled_he_image(adata, mpp=args.mpp, save_path=he_tiff_path, buffer=args.buffer, crop=True)

    # destripe data
    b2c.destripe(adata)

    # stardist segmentation
    he_npz_path = str(STARDIST_DIR / 'he.npz')
    b2c.stardist(image_path=he_tiff_path, 
                 labels_npz_path=he_npz_path, 
                 stardist_model="2D_versatile_he", 
                 prob_thresh=args.prob_thresh_he
                )

    # load resulting cell calls
    b2c.insert_labels(adata, 
                      labels_npz_path=he_npz_path, 
                      basis="spatial",
                      spatial_key=f"spatial_cropped_{args.buffer}_buffer",
                      mpp=args.mpp, 
                      labels_key="labels_he"
                     )

    # expand labels
    b2c.expand_labels(adata, 
                      labels_key='labels_he', 
                      expanded_labels_key="labels_he_expanded"
                     )

    # construct grid image
    gex_tiff_path = str(STARDIST_DIR / 'gex.tiff')
    b2c.grid_image(adata, "n_counts_adjusted", mpp=args.mpp, sigma=5, save_path=gex_tiff_path)

    # stardist using gex
    gex_npz_path = str(STARDIST_DIR / 'gex.npz')
    b2c.stardist(image_path=gex_tiff_path, 
                 labels_npz_path=gex_npz_path, 
                 stardist_model="2D_versatile_fluo", 
                 prob_thresh=args.prob_thresh_gex, 
                 nms_thresh=0.5
                )

    # insert new labels
    b2c.insert_labels(adata, 
                      labels_npz_path=gex_npz_path, 
                      basis="array", 
                      mpp=args.mpp, 
                      labels_key="labels_gex"
                     )

    # salvage secondary labels
    b2c.salvage_secondary_labels(adata, 
                               primary_label="labels_he_expanded", 
                                 secondary_label="labels_gex", 
                                 labels_key="labels_joint"
                                )

    # groups bins into cells
    cdata = b2c.bin_to_cell(adata, labels_key="labels_joint", spatial_keys=["spatial", f"spatial_cropped_{args.buffer}_buffer"])

    # update matrix to go back to integer
    convert_needed = False

    if issparse(cdata.X):
        if not np.all(np.mod(cdata.X.data, 1) == 0):
            convert_needed = True
            cdata.X.data = np.rint(cdata.X.data)
    else:
        chunk_size = 1000
        n_rows = cdata.X.shape[0]
        for start in range(0, n_rows, chunk_size):
            end = min(start + chunk_size, n_rows)
            chunk = cdata.X[start:end]
            if not np.all(np.mod(chunk, 1) == 0):
                convert_needed = True
                try:
                    np.rint(cdata.X, out=cdata.X)
                except MemoryError:
                    for start_chunk in range(0, n_rows, chunk_size):
                        end_chunk = min(start_chunk + chunk_size, n_rows)
                        np.rint(cdata.X[start_chunk:end_chunk], out=cdata.X[start_chunk:end_chunk])
                break


    # save anndata object output
    output_file = OUTDIR / f"{args.Identifier}_post_b2c.h5ad"
    cdata.write(output_file)

    # ==============================================
    # Step 4: Inform user it is finished
    # ==============================================
    print(f"[INFO] Bin2cell analysis completed for {args.Identifier}")
    print(f"[INFO] AnnData object saved at: {output_file}")
    print(f"[INFO] Stardist outputs saved in: {STARDIST_DIR}")
    


# ==============================================
# Run main
# ==============================================
if __name__ == "__main__":
    main()