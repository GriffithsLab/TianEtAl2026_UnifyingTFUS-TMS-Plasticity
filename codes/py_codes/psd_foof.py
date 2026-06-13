"""
Done by: Ravindu Upasena (PhD Student - University of New Brunswick)
Incorporated from Kevin Kadak's and Yupeng Tian's Implementations of psd_FOOF

Alpha peak normalization from Excel exports (one file per protocol).

Requirements:
- Five Excel files with columns: 'Time_s', 'V_e'
- psd_foof_funcs.py on PYTHONPATH (provides class PSD and FOOOF integration)

Outputs:
- CSV with per-protocol PrePW, PostPW, RelChange, NormDelta
- Bar plot of NormDelta ([-1, 1] max-abs normalization across protocols)
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from psd_foof_funcs import PSD

# ----------------------------- Config -----------------------------
# Map protocol label -> filename
files = {
    "A (3x5)": "V_e_3x5_timeseries.xlsx",
    "B (2x5)": "V_e_2x5_timeseries.xlsx",
    "C (3x3)": "V_e_3x3_timeseries.xlsx",
    "D (3x7)": "V_e_3x7_timeseries.xlsx",
    "E (5x5)": "V_e_5x5_timeseries.xlsx",
}

# Analysis windows (seconds) — adjust if you change onset/duration
PRE_WIN  = (2.0, 100.0)     # drop the first 2 s as warm-up of the baseline window
POST_WIN = (402.0, 500.0)   # well after TMS offset (onset 150 + duration 200 = 350)

# PSD/FOOOF settings
PSD_MIN_HZ = 1
PSD_MAX_HZ = 25
ALPHA_BAND = (7, 14)        # 8–13 also common;

# ------------------------- Helper functions ------------------------
def infer_fs_from_time(time_s: np.ndarray) -> float:
    """Infer sampling frequency from a Time_s column."""
    dt = np.median(np.diff(time_s))
    if dt <= 0:
        raise ValueError("Non-positive or degenerate time increments in Time_s.")
    return float(round(1.0 / dt))

def slice_window(df: pd.DataFrame, start_s: float, end_s: float) -> pd.Series:
    """Return V_e series between [start_s, end_s)."""
    seg = df[(df["t"] >= start_s) & (df["t"] < end_s)]["V_e"]
    if seg.empty:
        raise ValueError(f"No samples in window [{start_s}, {end_s}) s.")
    return seg.reset_index(drop=True)

def fooof_alpha_pw(series: pd.Series, fs: float) -> float:
    """
    Compute Welch PSD, fit FOOOF, and return the largest peak power (PW)
    within ALPHA_BAND. PW is aperiodic-corrected log power (FOOOF definition).
    Returns 0.0 if no peak is detected in band.
    """
    psd_obj = PSD(series, sampling_freq=fs, bin_min=PSD_MIN_HZ, bin_max=PSD_MAX_HZ)
    fm = psd_obj.fm(aperiodic_mode='knee')  # 'fixed' can be more stable for some data
    peaks = np.asarray(fm.peak_params_)     # columns: CF, PW, BW
    if peaks.size == 0:
        return 0.0
    cf, pw = peaks[:, 0], peaks[:, 1]
    mask = (cf >= ALPHA_BAND[0]) & (cf <= ALPHA_BAND[1])
    return float(pw[mask].max()) if np.any(mask) else 0.0

# ------------------------------ Main -------------------------------
rows = []
for label, path in files.items():
    # Read Excel
    df = pd.read_excel(path)
    if not {"t", "V_e"}.issubset(df.columns):
        raise ValueError(f"{path} must have columns: t, V_e")

    # Sampling rate from Time_s
    fs = infer_fs_from_time(df["t"].to_numpy())

    # Pre / Post segments
    pre_sig  = slice_window(df, PRE_WIN[0],  PRE_WIN[1])
    post_sig = slice_window(df, POST_WIN[0], POST_WIN[1])

    # FOOOF alpha PW
    pre_pw  = fooof_alpha_pw(pre_sig,  fs)
    post_pw = fooof_alpha_pw(post_sig, fs)

    # Relative change and safe handling if pre_pw == 0
    if pre_pw == 0:
        rel_change = np.nan
    else:
        rel_change = (pre_pw - post_pw) / pre_pw

    rows.append({
        "Protocol": label,
        "PrePW": pre_pw,
        "PostPW": post_pw,
        "RelChange": rel_change,
    })

# Assemble table and normalize to [-1, 1] by max-abs across protocols
table = pd.DataFrame(rows).set_index("Protocol")
max_abs = np.nanmax(np.abs(table["RelChange"].values))
table["NormDelta"] = table["RelChange"]

# Save results for reproducibility
table.to_csv("alpha_peak_changes.csv")
print(table)

# ---------------------------- Plot ------------------------------
fig, ax = plt.subplots(figsize=(9, 4.5))
table["NormDelta"].plot(kind="bar", ax=ax)
ax.set_title("Normalized change in alpha-band peak (FOOOF PW, 7–14 Hz)")
ax.set_xlabel("Protocol")
ax.set_ylabel("Normalized Delta (max-abs across protocols)")
ax.axhline(0, color="black", linewidth=1)
plt.tight_layout()
plt.show()

