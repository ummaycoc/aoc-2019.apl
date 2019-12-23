run ← { ⍝ (pc base) run program
  test ← {
    pc state ← ⍺[1 3]
    code ← ⊃state parseCode pc
    ~code∊1 2 5 6 7 8 9
  }
  pc base ← ⍺
  step⍣test pc base ⍵ ⍬ ⍬
}

writeInput ← { ⍝ writeInput pc base state squares white-squares dir outputs
  p b s sq w d o ← ⍵
  isw ← (1⊃sq)∊w
  i ← (PZ PO)[1+isw]
  p b s ← (step p b s i ⍬)[1 2 3]
  p b s sq w d o
}

readOutput ← { ⍝ readOutput pc base state squares white-squares dir outputs
  p b s sq w d o ← ⍵
  p b s oo ← (step p b s ⍬ ⍬)[1 2 3 5]
  o ,← fmtInt¨oo
  2>≢o: p b s sq w d o
  c t ← o
  d ×← (0J1 0J¯1)[1+t]
  pos ← 1⊃sq
  w ← (w≠pos)/w
  w ,← (c+1)⊃(⍬ (1⍴pos))
  pos +← d
  p b s (pos, sq) w d ⍬
}

robotStep ← { ⍝ robotStep pc base state squares white-squares dir outputs
  p b s sq w d o ← ⍵
  code ← ⊃s parseCode p
  3=code: writeInput ⍵
  4=code: readOutput ⍵
  p b s ← (p b run s)[1 2 3]
  p b s sq w d o
}

robot ← { ⍝ robot program → squares
  test ← {
    pc state ← ⍺[1 3]
    code ← ⊃state parseCode pc
    ~code∊⍳9
  }
  ⍝ robotStep pc base state squares white-squares dir outputs
  (robotStep⍣test) 0 PZ ⍵ (1⍴0) ⍬ 0J1 ⍬
}

painted ← { ≢∪¯1↓4⊃robot ⍵ }
