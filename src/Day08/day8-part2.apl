split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}

flatten ← { ⍝ layer-size flatten img-string
  layers ← (≢⍵)÷⍺
  image ← layers ⍺⍴⍵
  rows ← {1⍳⍨'2'≠image[;⍵]}¨⍳⍺
  indices ← 2 split(rows,⍳⍺)[⍋(⍳⍺),⍳⍺]
  image[indices]
}

decode ← { ⍝ (rows cols) decode input
  rows ← 1⊃⍺
  cols ← 2⊃⍺
  flat ← (rows×cols)flatten input
  disp ← '* '[1+'0'=flat]
  rows cols⍴disp
}
