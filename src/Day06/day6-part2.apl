parseOrbiting ← { ⍝ parseOrbiting string
  eoln ← 'UTF-8'⎕UCS 10
  orbits ← eoln (≠⊆⊢) input
  split ← {')'(≠⊆⊢)⍵}¨orbits
  ((⊃⌽)¨split) {(⊃⍺) (⊃⍵)}⌸ (⊃¨split)
}

path ← { ⍝ node-parent-matrix path start
  data ← ⍺
  calc ← { ⍝ (path level) -> (path' level')
    path ← ⊃⍵[1]
    level ← ⊃⍵[2]
    next ← data step level
    (path,(⊂,next)) (⊂,next)
  }
  ⌽¯1↓⊃calc⍣{0=≢⊃⊃⍺[2]}(⊂,⍵)(⊂,⍵)
}

transfers ← { ⍝ node-parent-matrix transfers (start end)
  ps ← ⍺ path⊃⍵[1]
  pe ← ⍺ path⊃⍵[2]
  short ← (≢ps)⌊(≢pe)
  diff ← ~(∧/)¨(short↑ps)=(short↑pe)
  mask ← {diff,((≢⍵)-short)⍴1}
  bs ← ≢¯1↓(mask ps)/ps
  be ← ≢¯1↓(mask pe)/pe
  bs+be-≠/0=bs be
}
