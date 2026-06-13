import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Each file must contain columns: "Protocol","Bursts","IBF","nu_ee(start)","nu_ee(end)"
files = {
    "A": "nu_ee_3x5.xlsx",   # 3 bursts at 5 Hz
    "B": "nu_ee_2x5.xlsx",   # 2 bursts at 5 Hz
    "C": "nu_ee_3x3.xlsx",   # 3 bursts at 3 Hz
    "D": "nu_ee_3x7.xlsx",   # 3 bursts at 7 Hz
    "E": "nu_ee_5x5.xlsx",   # 5 bursts at 5 Hz
}

rows = []
for label, path in files.items():
    df = pd.read_excel(path)
    # expect single row
    r = df.iloc[0]
    nu_start = float(r["nu_ee(start)"])
    nu_end   = float(r["nu_ee(end)"])
    delta    = nu_end - nu_start
    rows.append({
        "Label": label,
        "Protocol": str(r.get("Protocol", f"{int(r['Bursts'])}x{int(r['IBF'])}")),
        "Bursts": int(r["Bursts"]),
        "IBF": float(r["IBF"]),
        "nu_ee(start)": nu_start,
        "nu_ee(end)": nu_end,
        "Delta": delta,
        "PercentChange": (delta / abs(nu_start)) if nu_start != 0 else np.nan,  # optional
    })

table = pd.DataFrame(rows).sort_values("Label").reset_index(drop=True)

# ---- max-abs normalization (signed) ----
max_abs = np.max(np.abs(table["Delta"].values))
table["NormDelta"] = table["Delta"] / max_abs if max_abs > 0 else 0.0

# Save the normalized table (CSV avoids any Excel ZIP64 issues)
table.to_csv("nu_ee_normalized.csv", index=False)
print("Saved nu_ee_normalized.csv")
print(table[["Label","Protocol","Bursts","IBF","Delta","NormDelta"]])

# ---- bar plot  ----
fig, ax = plt.subplots(figsize=(8,4))
x = np.arange(len(table))
bars = ax.bar(x, table["NormDelta"].values, hatch='//', edgecolor='k')

# aesthetics
ax.axhline(0, color='k', linewidth=0.8)
ax.set_xticks(x, table["Label"].tolist())
ax.set_ylabel("Normalized Δ (by max |Δ|)")
ax.set_title("Normalized change in ν_ee by protocol")

# value labels on top
for b, val in zip(bars, table["NormDelta"].values):
    ax.text(b.get_x() + b.get_width()/2, 
            b.get_height() + (0.02 if val>=0 else -0.06), 
            f"{val:.2f}", ha='center', va='bottom' if val>=0 else 'top')

plt.tight_layout()
plt.show()
