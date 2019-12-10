split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}

parseOp ← { ⍝ state parseOp counter → code (input addrs) (output addrs)
  parsed ← 10 10 10 100⊤⍺[1+⍵]
  modes ← ⌽1+3↑parsed
  code ← ¯1↑parsed
  imm ← ⍵+⍳3
  pos ← ⍺[(1+imm)⌊≢⍺]
  idx ← (modes,⍳3)[⍋(⍳3),⍳3]
  addrs ← (2 3⍴pos,imm)[2 split idx]
  nin ← (2 2 0 1 2 2 2 2)[code]
  nout ← (1 1 1 0 0 0 1 1)[code]
  ins ← nin↑addrs
  addrs ← nin↓addrs
  outs ← nout↑addrs
  code ins outs
}

step ← { ⍝ step (program-counter state input output)
  p ← ⊃⍵[1]
  s ← ⊃⍵[2]
  i ← ⊃⍵[3]
  o ← ⊃⍵[4]
  parsed ← s parseOp p ⍝ has code (input addrs) (output addrs)
  code ← ⊃parsed[1]
  ins ← s[1+⊃parsed[2]]
  outs ← 1+⊃parsed[3]
  output ← ∊o,∊(⍬ ⍬ ⍬ ins ⍬ ⍬ ⍬ ⍬)[code]
  res ← ∊((+/ins) (×/ins) (⊃1↑i,0) 0 0 0 (</ins) (=/ins))[code]
  next ← p+1+≢∊ins,outs
  jump ← (∊ins,0,0)[2]
  zero ← 0=(∊ins,0)[1]
  jnz ← (next jump)[1+~zero]
  jz ← (next jump)[1+zero]
  p ← (next next next next jnz jz next next)[code]
  s[∊outs] ← ∊(res res res ⍬ ⍬ ⍬ res res)[code]
  (⊃p) s ((code=3)↓i) output
}

run ← { ⍝ input-stream run program
  test ← {
    pc ← ⊃⍺[1]
    state ← ⊃⍺[2]
    code ← 100|state[1+pc]
    ~code∊1 2 3 4 5 6 7 8
  }
  program ← ⍵
  input ← ⍺
  output ← ⍬
  step⍣test 0 program input output
}

rows ← { ⍝ rows mat
  mat ← ⍵
  {mat[⍵;]}¨⍳(⍴mat)[1]
}

perms ← { ⍝ perms vector → matrix of perms
  il ← { ⍝ val il vec
    val ← ⍺
    vec ← ⍵
    n ← 1+≢vec
    n n⍴∊{(⍵↑vec),val,(⍵↓vec)}¨¯1+⍳n
  }
  ilm ← { ⍝ value ilm matrix
    val ← ⍺
    ⊃,[1]/{val il ⍵}¨rows ⍵
  }
  init ← 1 1⍴⍵,0
  items ← 1↓⍵
  next ← { ⍝ next index matrix → index' matrix'
    idx ← ⍵[1]
    mat ← ⊃⍵[2]
    (1+idx) (items[idx] ilm mat)
  }
  res ← 2⊃(next⍣(≢items)) 1 init
  ⊃(res ⍬)[1+0=≢⍵]
}

maxamp ← { ⍝ maxamp program
  prg ← ⍵
  amp ← {
    res ← ⊃((⌽2↑⍵)run prg)[4]
    res,2↓⍵
  }
  ⌈/{⊃(amp⍣5)0,⍵}¨rows perms ¯1+⍳5
}
