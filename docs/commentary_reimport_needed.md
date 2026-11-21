# Commentary entries that need re-import

These entries are corrupt at the word level: the scan turned whole words into character soup, so no rule in `tool/clean_commentary.py` can rebuild them. They are deliberately left **untouched** by `--mechanical` (a half-cleaned copy only hides the damage) and need the passage re-imported from a clean edition, or retyped.

19 entries:

| # | id | source | scope | garbled text |
|---|---|---|---|---|
| 1 | `c_da_0089988b` | The Desire of Ages | book (Matthew) | `s,coinmg`, `ha4` |
| 2 | `c_da_5966d52c` | The Desire of Ages | book (Mark) | `r;uii`, `i.vcvy` |
| 3 | `c_da_991f644d` | The Desire of Ages | book (Matthew) | `will.be`, `i8` |
| 4 | `c_da_b8569e76` | The Desire of Ages | book (John) | `th.at`, `decided,change` |
| 5 | `c_th_06e5090d` | The Desire of Ages | John 3 | `j:o` |
| 6 | `c_th_0b0e7ca6` | The Desire of Ages | John 4:52 | `v;kn` |
| 7 | `c_th_19b5452b` | The Desire of Ages | Luke 19:32 | `wha;t` |
| 8 | `c_th_30d6af90` | The Desire of Ages | Matthew 27:31 | `Ik.LisLij` |
| 9 | `c_th_4b11de6c` | The Desire of Ages | Luke 2:15 | `JF,v` |
| 10 | `c_th_4f247427` | The Desire of Ages | Matthew 4:4 | `ItJ.sjjmtten` |
| 11 | `c_th_813190cb` | The Desire of Ages | John 2:3 | `H:s` |
| 12 | `c_th_8249134f` | The Desire of Ages | Matthew 2:6 | `Heb.n` |
| 13 | `c_th_aabd1822` | The Desire of Ages | Matthew 28:11 | `eWs.Jl`, `slept1` |
| 14 | `c_th_b2ec8589` | The Desire of Ages | Luke 2:15 | `h.ng` |
| 15 | `c_th_b5fb54fd` | The Desire of Ages | Luke 24:44 | `Beginning,s`, `s£olje`, `F£d` |
| 16 | `c_th_bb4f744e` | The Desire of Ages | John 13:1 | `e.JI` |
| 17 | `c_th_bd6b5d00` | The Desire of Ages | Luke 2:18 | `merv;J` |
| 18 | `c_th_c286c1e2` | The Desire of Ages | Luke 10:21 | `io:S` |
| 19 | `c_th_cb2a8dfb` | The Desire of Ages | John 3:26 | `fR.V` |

## Flagged while cleaning

These three carry corruption other than the mechanical artifacts, so they were not in the original 19 but will need the same treatment:

| id | source | scope | evidence |
|---|---|---|---|
| `c_th_34f3950a` | The Desire of Ages | John 3:15 | "God a. 64:6; Ps. 51:10; £26.36:26, 27." — mangled scripture references |
| `c_pa_81440772` | Patriarchs and Prophets | Genesis 3:24 | "p.p.P.a. and wisdom." — scanner debris left after its page marker was cleaned |
| `c_pa_e07d5c12` | Patriarchs and Prophets | Genesis 4:11 | "it men meena ne ccliaieiaiet" — word soup |

## Already cleaned

The mechanical pass (`python3 tool/clean_commentary.py --mechanical --write`) rewrote 150 entries: `:--` / `,--` / `;--` became em dashes, inline `[Illustration: …]` plate captions were dropped, and leaked page numbers (`{ 88-891 67`, `108 £ 125-126 1`) were removed. It skips every id listed above.

Word-level mis-reads in entries *not* listed here (for example `tne` for "the") are outside both the mechanical pass and these 22 entries; they are worth a separate sweep against a dictionary of the era.
