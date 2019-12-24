split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}

parseMoons ← { ⍝ parseMoons moonString
  moons ← ⍵
  ((moons='-')/moons) ← '¯'
  ((moons=⎕UCS 10)/moons) ← ','
  ↑3 split⍎(moons∊'¯0123456789,')/moons
}

gravity ← { {(+⌿⍵)-(+/⍵)}(⊢∘.>⊢)⍵ }

sim ← { ⍝ n sim moons
  step ← {
    p v ← ⍵
    v+ ← ⍉↑gravity¨↓[1]p
    (p+v) v
  }
  (step⍣⍺) ⍵ ((⍴⍵)⍴0)
}

energy ← { +/×⌿↑(+/)¨|⍺ sim ⍵ }
