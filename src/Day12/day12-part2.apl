period ← { ⍝ periods pos-vec
  ipos ← ⍵
  ivel ← (⍴⍵)⍴0
  step ← { ⍝ step pos vel n
    pos vel n ← ⍵
    vel + ←gravity pos
    pos + ←vel
    pos vel (1+n)
  }
  test←{ ⍝ test pos vel n
    pos vel ← ⍺[1 2]
    ∧/(pos,vel)=(ipos,ivel)
  }
  3⊃(step⍣test) ⍵ ivel 0
}

sim ← { ∧/period¨↓[1] parseMoons ⍵ }
