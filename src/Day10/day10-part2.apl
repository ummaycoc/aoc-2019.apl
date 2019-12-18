readUTF8 ← { ¯1↓1⊃'UTF-8'⎕NGET ⍵ }
parseMap ← { '#'=↑⍵⊆⍨~⍵=⎕UCS 10 }
asteroids ← { (,⍵)/,⌽¨⊖¯1+⍳⍴⍵ }
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

skey ← { idx ← ⍋⍵ ⋄ ⍵[idx] ⍺⍺ ⌸ ⍺[idx] }
complex ← { ⍵[1] + 0J1×⍵[2] }
flip ← { (-9○⍵) + (0J1×11○⍵) }
rot ← { 0J1×⍵ }
degrees ← { 360|(180÷○1)×12○⍵ }
dist ← { 0.5*⍨+/⍵*2 }
sort ← { ⍵[⍋dist¨⍵] }
group ← { ⍵ {⍺ ⍵} skey degrees flip rot complex¨dirs ⍵ }
merge ← { (⊃,/⍵)[⍋⊃,/⍳¨≢¨⍵] }

translate ← {
  m p ← ⍺
  c ← (⍴m)[2]
  { (c-p[2]+⍵[2]), (p[1]+1+⍵[1]) }¨⍵
}

laser ← { ⍝ laser map
  counts points ← (countDirs asteroids ⍵)[1 2]
  idx ← counts⍳⌈/counts
  pos ← idx⊃points
  others ← (idx≠⍳≢points)/points
  grouped ← group sort pos center others
  ⍵ pos translate merge grouped[;2]
}

last ← { 100 ⊥ ⌽¯1 + ⍺ ⊃ laser parseMap ⍵ }
