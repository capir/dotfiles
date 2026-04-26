import subprocess, sys, pathlib

SCRIPT = pathlib.Path(__file__).resolve().parent.parent / "timefocus.py"

def test_version_flag_prints_version():
    r = subprocess.run([sys.executable, str(SCRIPT), "--version"],
                       capture_output=True, text=True, timeout=5)
    assert r.returncode == 0
    assert r.stdout.strip() == "0.1.0"
