split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}

checkprod ← { ⍝ layer-size checkprod img-string
  layers ← ⍺ split ⍵
  stats ← 100 3⍴∊{+/¨('0'=⍵)('1'=⍵)('2'=⍵)}¨layers
  row ← (stats[;1]=⌊/stats[;1])⍳1
  ×/stats[row;2 3]
}
