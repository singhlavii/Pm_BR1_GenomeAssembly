#!/usr/bin/env python3
"""
Convert FindTelomeres.py output to ChromoMap annotation format.
Also reads .fai file to get scaffold sizes for end telomere positions.
"""

import sys

# ============================================================
# INPUT FILES — update these paths if needed
# ============================================================
telomere_file = "/scratch/xf3/ls9057/Pmelanocephala/scripts/telomeres_v2_20260829.txt"
fai_file      = "/scratch/xf3/ls9057/Pmelanocephala/Pm_asm_30Gb/Pm_hap12_3ddna_v2_20260829.fasta.fai"
output_file   = "/scratch/xf3/ls9057/Pmelanocephala/scripts/telomere_annotation_3ddna_v2_202608209.txt"

# Window size for telomere annotation (bp)
TELO_WINDOW = 50000  # 50kb window at each end

# ============================================================
# STEP 1 — Read scaffold sizes from .fai
# ============================================================
print("Reading scaffold sizes from .fai file...")
scaffold_sizes = {}
with open(fai_file) as f:
    for line in f:
        parts = line.strip().split("\t")
        if len(parts) >= 2:
            scaffold_sizes[parts[0]] = int(parts[1])

print(f"  Found {len(scaffold_sizes)} scaffolds")

# ============================================================
# STEP 2 — Parse FindTelomeres output
# ============================================================
print("Parsing FindTelomeres output...")

telomeres = []  # list of (scaffold, start, end, label)

with open(telomere_file) as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("Telomeres"):
            continue

        parts = line.split("\t")
        if len(parts) < 2:
            continue

        scaffold = parts[0].strip()
        direction = parts[1].strip()

        # Get scaffold size
        size = scaffold_sizes.get(scaffold, 0)
        if size == 0:
            print(f"  WARNING: {scaffold} not found in .fai file")
            continue

        if "Forward" in direction or "start" in direction.lower():
            # Telomere at start of sequence
            start = 1
            end = min(TELO_WINDOW, size - 1)
            label = "telomere_start"
        elif "Reverse" in direction or "end" in direction.lower():
            # Telomere at end of sequence
            start = max(1, size - TELO_WINDOW)
            end = size - 1
            label = "telomere_end"
        else:
            continue

        telomeres.append((scaffold, start, end, label))
        print(f"  {scaffold}: {label} at {start}-{end}")

print(f"  Found {len(telomeres)} telomere annotations")

# ============================================================
# STEP 3 — Write ChromoMap annotation file
# Format: name, chromosome, start, end
# ============================================================
print(f"Writing annotation file to {output_file}...")

with open(output_file, "w") as f:
    # Header
    f.write("name\tchrom\tstart\tend\ttype\n")
    for i, (scaffold, start, end, label) in enumerate(telomeres, 1):
        f.write(f"telo_{i}\t{scaffold}\t{start}\t{end}\t{label}\n")

print(f"\nDone! Output file: {output_file}")
print(f"  Total telomere annotations: {len(telomeres)}")
print(f"  Start telomeres: {sum(1 for t in telomeres if t[3]=='telomere_start')}")
print(f"  End telomeres: {sum(1 for t in telomeres if t[3]=='telomere_end')}")
