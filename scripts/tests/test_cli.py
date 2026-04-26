import os
import subprocess, sys, pathlib

SCRIPT = pathlib.Path(__file__).resolve().parent.parent / "timefocus.py"

def test_version_flag_prints_version():
    r = subprocess.run([sys.executable, str(SCRIPT), "--version"],
                       capture_output=True, text=True, timeout=5)
    assert r.returncode == 0
    assert r.stdout.strip() == "0.1.0"

def test_help_flag_exits_zero():
    r = subprocess.run([sys.executable, str(SCRIPT), "--help"],
                       capture_output=True, text=True, timeout=5)
    assert r.returncode == 0
    assert "Usage" in r.stdout or "usage" in r.stdout

def test_man_flag_prints_manual():
    r = subprocess.run([sys.executable, str(SCRIPT), "--man"],
                       capture_output=True, text=True, timeout=5)
    assert r.returncode == 0
    assert "INSTALL" in r.stdout
    assert "TROUBLESHOOTING" in r.stdout

def test_once_dry_run_completes(tmp_path):
    env = dict(**os.environ,
               TIMEFOCUS_STATE_DIR=str(tmp_path),
               TIMEFOCUS_CACHE_DIR=str(tmp_path),
               TIMEFOCUS_CONFIG=str(tmp_path/"none.toml"))
    r = subprocess.run([sys.executable, str(SCRIPT), "--once", "--dry-run"],
                       capture_output=True, text=True, timeout=10, env=env)
    assert r.returncode == 0
