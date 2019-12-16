peel ← { ⍝ boolean-vec peel digits
  nz ← ⍺⍳1
  mask ← nz≤⍳≢⍵
  d ← mask/⍵
  d,(0=≢d)⍴0
}

trim ← { ⍝ trim digits: removes leading zeroes
  (0≠⍵) peel ⍵
}

pad ← { ⍝ digits pad digits → (digits' digits')
  max ← 1⌈(≢⍺)⌈(≢⍵)
  {((max-≢⍵)⍴0),⍵}¨⍺ ⍵
}

parseNum ← { ⍝ parseNum string -> (sign, digits)
  neg ← (⍵,'0')[1]∊'¯-'
  num ← neg↓⍵
  neg ← neg×0<≢num
  d ← trim ⍎¨'0',num
  s ← (d[1]≠0)×(1 ¯1)[1+neg]
  s d
}

fmt ← { ⍝ fmt num
  sign digits ← ⍵
  ⊃,/('¯' '' '')[2+sign],⍕¨digits
}

fmtInt ← { (1⊃⍵)×10⊥(2⊃⍵) }

snum ← { (parseNum ⍺) ⍺⍺ (parseNum ⍵) }
fnum ← { fmt (parseNum ⍺) ⍺⍺ (parseNum ⍵) }

carry ← { ⍝ carry num
  carryon ← { ⍝ (c din dout) → (c' din' dout')
    cin din dout ← ⍵
    s ← cin+1↑din,0
    d ← 10|s
    cout ← (s-d)÷10
    cout (1↓din) (dout,d)
  }
  sign digits ← ⍵
  done ← {
    cin din dout ← ⍺
    0=cin⌈≢din
  }
  res ← (carryon⍣done) 0 (⌽digits) ⍬
  sign (⌽3⊃res)
}

borrow ← { ⍝ borrow num-with-negs → num
  brw ← { ⍝ brw din dout → brw' din' dout'
    bin din dout ← ⍵
    s ← (1⊃din)-bin
    d ← 10|s
    bout ← ¯10÷⍨s-d
    bout (1↓din) (d,dout)
  }
  s d ← ⍵
  s (trim 3⊃(brw⍣{0=≢2⊃⍺})0(⌽trim d)⍬)
}

eq ← { ⍝ num eq num
  ⍺[1]≠⍵[1]: 0
  (≢2⊃⍺)≠(≢2⊃⍵): 0
  ∧/⊃⍺[2]=⍵[2]
}

ne ← { ⍝ num ne num
  ~⍺ eq ⍵
}

gt ← { ⍝ num gt num
  ls ld ← ⍺
  rs rd ← ⍵
  ld rd ← ld pad rd
  ne ← ld≠rd
  ld ← ne peel ld
  rd ← ne peel rd
  greater ← ld[1]>rd[1]
  lesser ← ld[1]<rd[1]
  pos ← ∧/1=ls rs
  neg ← ∧/¯1=ls rs
  (ls>rs) ∨ (pos∧greater) ∨ (neg∧lesser)
}

ge ← { ⍝ num ge num
  ~⍵ gt ⍺
}

lt ← { ⍝ num lt num
  ⍵ gt ⍺
}

le ← { ⍝ num le num
  ~⍺ gt ⍵
}

abs ← { ⍝ abs num
  s d ← ⍵
  (|s) d
}

neg ← { ⍝ num → neg of num
  s d ← ⍵
  (¯1×s) d
}

sub ← { ⍝ a sub b → a-b
  ⍺ eq ⍵: 0(1⍴0)
  (abs ⍺) eq (abs ⍵): carry (⍺[1]) (2×2⊃⍺)
  lbig ← (abs ⍺) gt (abs ⍵)
  bs bd ← (1+lbig)⊃⍵ ⍺
  ss sd ← (1+~lbig)⊃⍵ ⍺
  bd sd ← bd pad sd
  sign ← bs×(¯1 1)[1+lbig]
  fs fd ← borrow sign (bd-sd)
  fs (trim fd)
}

add ← { ⍝ num add num
  ls ld ← ⍺
  rs rd ← ⍵
  ∧/0=ls rs: 0(1⍴0)
  0=ls×rs: (1+0=ls)⊃⍺ ⍵
  ls=rs: carry ls(⊃+/ld pad rd)
  ⍝ One of ls and rs is 1 and the other ¯1
  ls<0: ⍵ sub(abs ⍺)
  ⍺ sub(abs ⍵)
}

mul ← { ⍝ num mul num → num
  lbig ← (abs ⍺)ge(abs ⍵)
  bs bd ← (1+lbig)⊃(⍵ ⍺)
  ss sd ← (1+~lbig)⊃(⍵ ⍺)
  lz ← ¯1+⍳≢sd
  rz ← ⌽lz
  row ← {(lz[⍵]⍴0),(sd[⍵]×bd),(rz[⍵]⍴0)}
  carry (bs×ss) (trim+⌿↑row¨⍳≢sd)
}
