readUTF8 ← { ¯1↓1⊃'UTF-8'⎕NGET ⍵ }
parseMap ← { '#'=↑⍵⊆⍨~⍵=⎕UCS 10 }
asteroids ← { (,⍵)/,⍳⍴⍵ }
dirs ← { {⍵÷∨/⍵}¨⍵ }
center ← { pt ← ⍺ ⋄ {⍵-pt}¨⍵ }
countDirs ← { ⍝ countDirs asteroids
  step ← { ⍝ step counts done todo
    c d t ← ⍵
    p ← 1⊃t
    t ← 1↓t
    qty ← ≢∪dirs p center d,t
    (c,qty) (d,⊂p) t
  }
  (step⍣{0=≢⊃⌽⍺}) ⍬ ⍬ ⍵
}
find ← { ⌈/1⊃countDirs asteroids parseMap ⍵ }
