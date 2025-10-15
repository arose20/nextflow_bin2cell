// modules/test_environment.nf
// Module that tests environment access and Python package availability

nextflow.enable.dsl=2

process test_environment {  // <-- make the process name lowercase for consistent import
    tag "test_env"

    input:
    val env_home
    val env_name

    output:
    path "env_test_done.txt"

    script:
    """
    echo "[INFO] ==========================================="
    echo "[INFO] Testing access to Conda environment"
    echo "[INFO] Conda base: ${env_home}"
    echo "[INFO] Target environment: ${env_name}"
    echo "[INFO] ==========================================="

    ENV_PATH="${env_home}/${env_name}"

    if [ ! -d "\$ENV_PATH" ]; then
        echo "[ERROR] Environment directory not found: \$ENV_PATH"
        exit 1
    fi

    echo "[INFO] Environment directory found: \$ENV_PATH"

    # Try activating Conda environment
    echo "[INFO] Attempting to activate environment..."
    if [ -f "\$(conda info --base)/etc/profile.d/conda.sh" ]; then
        source "\$(conda info --base)/etc/profile.d/conda.sh"
        conda activate "\$ENV_PATH" || { echo "[ERROR] Failed to activate environment"; exit 1; }
    else
        echo "[ERROR] Could not find conda.sh — check your Conda installation"
        exit 1
    fi

    echo "[INFO] Testing Python inside environment..."

    python - <<'PY'
import importlib

required_packages = [
    "os",
    "numpy",
    "pandas",
    "scanpy",
    "bin2cell",
    "scipy",
    "argparse",
    "pathlib",
    "PIL",
    "cv2"
]

print("[INFO] Checking required Python packages...")

missing = []
for pkg in required_packages:
    try:
        importlib.import_module(pkg)
        print(f"[OK]   {pkg} imported successfully.")
    except Exception as e:
        print(f"[ERROR] {pkg} failed to import: {e}")
        missing.append(pkg)

if missing:
    print(f"\\n[ERROR] Missing or broken packages: {', '.join(missing)}")
    raise SystemExit(1)
else:
    print("\\n[INFO] ✅ All required Python packages imported successfully.")
PY

    echo "[INFO] ✅ Environment test passed successfully!"
    echo "ok" > env_test_done.txt
    """
}
