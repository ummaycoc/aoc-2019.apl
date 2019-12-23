robot ← { ⍝ white-squares robot program → squares
  test ← {
    pc state ← ⍺[1 3]
    code ← ⊃state parseCode pc
    ~code∊⍳9
  }
  ⍝ robotStep pc base state squares white-squares dir outputs
  (robotStep⍣test) 0 PZ ⍵ (1⍴0) ⍺ 0J1 ⍬
}

points ← { ⍝ points white-spaces
  w ← ⍵-(¯1+⌊/9○⍵)+(¯1+⌊/11○⍵)×0J1
  ⊖(⍳(⌈/11○w)(⌈/9○w))∊↓[1]↑(11○w)(9○w)
}

paint ← { ' *'[1+points 5⊃⍺ robot ⍵] }
