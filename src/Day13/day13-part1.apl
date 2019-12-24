⍝ Use the intcode computer from before with the generic run function

tiles ← { (0=3|⍳≢⍵)/⍵ }

blocks ← { +/2=tiles ⍵ }

count ← { blocks fmtInt¨5⊃⍬ run parseProgram ⍵ }
