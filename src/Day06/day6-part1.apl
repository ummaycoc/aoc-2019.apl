parseOrbits ← { ⍝ parseOrbits string
  eoln ← 'UTF-8'⎕UCS 10
  orbits ← eoln (≠⊆⊢) input
  split ← {')' (≠⊆⊢) ⍵}¨orbits
  (⊃¨split) {(⊃⍺)⍵}⌸ ((⊃⌽)¨split)
}

step ← { ⍝ adj-list-rep step objects → orbiters
  nodes ← ⍺[;1]
  nbrs ← ⍺[;2]
  mask ← ⊃∨/{(⊂,⍵)⍷nodes}¨⍵
  ⊃,/mask/nbrs
}

checksum ← { ⍝ adj-list-rep
  data ← ⍵
  calc ← { ⍝ (sum depth level) -> (sum' depth' level')
    sum ← ⍵[1]
    depth ← ⍵[2]
    level ← ⊃⍵[3]
    (sum+depth×≢level) (depth+1) (data step level)
  }
  calc⍣{0=≢⊃⍵[3]} 0 0 (⊂,'COM')
}
