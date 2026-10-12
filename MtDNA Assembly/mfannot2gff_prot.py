#!/usr/bin/env python3
"""
Convert an MFannot masterfile (.new) into a GFF3 and protein FASTA (genetic code 4 by default).
Usage: python3 mfannot2gff_prot.py <masterfile.new> <out_prefix> [genetic_code]
"""
import re, sys
from collections import OrderedDict

mf, prefix = sys.argv[1], sys.argv[2]
gcode = int(sys.argv[3]) if len(sys.argv) > 3 else 4

seqid, seq = None, []
bounds = OrderedDict()
nextpos = 1
mark = re.compile(r'^;+\s+G-(\S+)\s+(==>|<==)\s+(start|end)\b')
with open(mf) as fh:
    for line in fh:
        line = line.rstrip('\n')
        if line.startswith('>'):
            seqid = line[1:].split()[0]; continue
        if line.startswith(';'):
            m = mark.match(line)
            if m:
                name, arrow, _ = m.groups()
                d = bounds.setdefault(name, {'strand': '+' if arrow == '==>' else '-', 'b': []})
                d['b'].append(nextpos)
            continue
        m = re.match(r'^\s*(\d+)\s+(.*)$', line)
        if m:
            start = int(m.group(1))
            bases = re.sub(r'[^A-Za-z]', '', m.group(2))
            if start != nextpos:
                sys.exit(f"position mismatch at line: {line[:40]} (expected {nextpos})")
            seq.append(bases); nextpos = start + len(bases)
seq = ''.join(seq); L = len(seq)

feat = {}
for name, d in bounds.items():
    if len(d['b']) != 2:
        print(f"WARNING: {name} has {len(d['b'])} boundaries, skipped", file=sys.stderr); continue
    lo, hi = d['b'][0], d['b'][1] - 1
    if hi < lo:
        print(f"WARNING: {name} wraps the origin ({lo}..{hi}), skipped", file=sys.stderr); continue
    feat[name] = (lo, hi, d['strand'])

B = 'TCAG'
std = 'FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG'
table = {a+b+c: std[16*i+4*j+k] for i,a in enumerate(B) for j,b in enumerate(B) for k,c in enumerate(B)}
if gcode == 4: table['TGA'] = 'W'
elif gcode != 1: sys.exit("only genetic codes 1 and 4 are implemented")
STARTS = {'TTA','TTG','CTG','ATT','ATC','ATA','ATG','GTG'} if gcode == 4 else {'TTG','CTG','ATG'}
comp = str.maketrans('ACGTacgtNn', 'TGCAtgcaNn')
rc = lambda s: s.translate(comp)[::-1]
translate = lambda nt: ''.join(table.get(nt.upper()[i:i+3], 'X') for i in range(0, len(nt)-2, 3))

is_part = re.compile(r'-(E|I)\d+$')
def kind(n):
    if n.startswith('trn'): return 'tRNA'
    if n in ('rns', 'rnl', 'rrn5'): return 'rRNA'
    if n == 'rnpB': return 'ncRNA'
    if is_part.search(n): return 'part'
    return 'protein'

gff = ["##gff-version 3", f"##sequence-region {seqid} 1 {L}"]
prots, qc = [], []
for name, (lo, hi, st) in sorted(feat.items(), key=lambda x: x[1][0]):
    k = kind(name)
    if k == 'part': continue
    gid = f"gene-{name}"
    gff.append(f"{seqid}\tMFannot\tgene\t{lo}\t{hi}\t.\t{st}\t.\tID={gid};Name={name};gene={name}")
    if k in ('tRNA', 'rRNA', 'ncRNA'):
        gff.append(f"{seqid}\tMFannot\t{k}\t{lo}\t{hi}\t.\t{st}\t.\tID={k}-{name};Parent={gid};Name={name};gene={name}")
        continue
    exons = sorted([(v[0], v[1]) for n, v in feat.items() if re.fullmatch(re.escape(name) + r'-E\d+', n)])
    introns = sorted([(v[0], v[1], n) for n, v in feat.items() if re.fullmatch(re.escape(name) + r'-I\d+', n)])
    if not exons: exons = [(lo, hi)]
    for a, b, n in introns:
        gff.append(f"{seqid}\tMFannot\tintron\t{a}\t{b}\t.\t{st}\t.\tID=intron-{n};Parent={gid};Name={n}")
    nt = ''.join(seq[a-1:b] for a, b in exons)
    if st == '-': nt = rc(nt)
    aa = translate(nt)
    # alternative start codons (table 4) translate as M; others (e.g. intron ORFs, /first_aa) stay as is
    if aa and nt[:3].upper() in STARTS: aa = 'M' + aa[1:]
    term = aa.endswith('*'); core = aa[:-1] if term else aa
    phase = 0
    for a, b in (exons if st == '+' else exons[::-1]):
        gff.append(f"{seqid}\tMFannot\tCDS\t{a}\t{b}\t.\t{st}\t{phase}\tID=cds-{name};Parent={gid};Name={name};gene={name};transl_table={gcode}")
        phase = (3 - ((b - a + 1 - phase) % 3)) % 3
    prots.append((name, core))
    qc.append((name, len(nt), len(nt) % 3, core.count('X'), core.count('*'), term))

open(prefix + '.gff3', 'w').write('\n'.join(gff) + '\n')
with open(prefix + '.proteins.faa', 'w') as o:
    for n, aa in prots:
        o.write(f">{n}\n" + '\n'.join(aa[i:i+60] for i in range(0, len(aa), 60)) + '\n')
with open(prefix + '.protein_qc.tsv', 'w') as o:
    o.write("gene\tcds_nt\tnt_mod3\tX\tinternal_stops\tends_with_stop\n")
    for r in qc: o.write('\t'.join(map(str, r)) + '\n')

n = lambda k: sum(1 for x in feat if kind(x) == k)
print(f"sequence {seqid}: {L} bp")
print(f"protein-coding/ORF: {n('protein')}  tRNA: {n('tRNA')}  rRNA: {n('rRNA')}  ncRNA: {n('ncRNA')}")
bad = [r for r in qc if r[2] != 0 or r[4] > 0 or not r[5]]
print(f"proteins written: {len(prots)};  with problems: {len(bad)}")
for r in bad:
    print("  CHECK", r[0], f"nt={r[1]} mod3={r[2]} internal_stops={r[4]} ends_with_stop={r[5]}")
