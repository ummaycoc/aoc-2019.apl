fuel ← { ⍝ first row is next mass, second row is fuel so far
  e ← 0⌈(¯2)+⌊(⍵[1;])÷3
  (⍴⍵)⍴∊e(e+⍵[2;])
}

⍝ Pass the vector of all module masses to this to get the total fuel required
⍝ to launch everything, fuel included.
total ← {+/∊(fuel⍣{∧/∊⍺=⍵})(∊2(⍴⍵))⍴(⍵,(⍴⍵)⍴0)}
