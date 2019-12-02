fuel ← { ⍝ (next-mass, sum-so-far)
  e ← 0⌈(¯2)+⌊(⊃⍵)÷3
  e (e+⊃⌽⍵)
}

total ← {⊃⌽(fuel⍣{⊃⍺=⍵}) ⍵ 0}

⍝ Pass the masses of all the modules to this to get the total fuel requirements
⍝ for all of the modules.
totalFuel ← {+/total¨⍵}
