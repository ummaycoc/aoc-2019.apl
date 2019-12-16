PZ ← parseNum '0'
PO ← parseNum '1'

parseProgram ← { ⍝ parseProgram programString
  idx ← (⍵='-')/⍳≢⍵
  prg ← ⍵
  prg[idx] ← ('¯'⍬)[1+0=≢idx]
  parseNum¨(prg≠',')⊆prg
}

parseCode ← { ⍝ state parseCode pc
  m3 m2 m1 c10 c1 ← ⌽5↑⌽(5⍴0),2⊃(1+⍵)⊃⍺
  (c1+c10×10) (1+m1 m2 m3)
}

parseOp ← { ⍝ state parseOp (counter, base) → code (input addrs) (output addrs)
  pc base ← ⍵
  code modes ← ⍺ parseCode pc
  nin ← (2 2 0 1 2 2 2 2 1)[code]
  nout ← (1 1 1 0 0 0 1 1 0)[code]
  nt ← nin+nout
  modes ← modes[⍳nt]
  imm ← pc+⍳nt
  pos ← (⍺,3⍴⊂PZ)[1+imm]
  rel ← {base add ⍵}¨pos
  imm ← {carry 1(1⍴⍵)}¨imm
  idx ← (modes,⍳nt)[⍋(⍳nt),⍳nt]
  addrs ← (↑pos imm rel)[2 split idx]
  addrs ← {10⊥2⊃⍵}¨addrs,⊂PZ ⍝ Ensures a vector
  ins ← nin↑addrs
  addrs ← nin↓addrs
  outs ← nout↑addrs
  code ins outs
}

expand ← { ⍝ state expand mems
  max ← ⌈/⍵
  ⍺,(0⌈1+max-≢⍺)⍴⊂PZ
}

advance ← { ⍝ code res advance pc base inputs outputs
  code res ← ⍺
  p b ins outs ← ⍵
  next ← p+1+≢ins,outs
  jump ← 10⊥2⊃2⊃ins,(⊂PZ),(⊂PZ)
  zero ← 0=10⊥2⊃1⊃ins,(⊂PZ)
  jnz ← (next jump)[1+~zero]
  jz ← (next jump)[1+zero]
  p ← (next jnz jz)[1+(code∊5 6)+(code=6)]
  9≠code: p b
  p (b add res)
}

compute ← { ⍝ code compute (values, inputs)
  v i ← ⍵
  ⍺=3: 1⊃i,⊂PZ
  ⍺∊4 5 6: PZ
  ⍺=9: 1⊃v
  l r ← v
  ⍺=1: l add r
  ⍺=2: l mul r
  ⍺=7: (1+l lt r)⊃(PZ PO)
  ⍺=8: (1+l eq r)⊃(PZ PO)
}

step ← { ⍝ step (program-counter base state input output)
  p b s i o ← ⍵
  parsed ← s parseOp(p b) ⍝ has code (input addrs) (output addrs)
  code ← parsed[1]
  s ← s expand∊parsed[2 3]
  ins ← s[1+⊃parsed[2]]
  outs ← 1+⊃parsed[3]
  output ← o,code⊃(⍬ ⍬ ⍬ ins ⍬ ⍬ ⍬ ⍬ ⍬)
  res ← code compute(ins i)
  p b ← code res advance p b ins outs
  s[outs] ← (⍬ res)[1+0<≢outs]
  i ← (code=3)↓i
  p b s i output
}

⍝ We can run an intcode program with the following:
⍝   input-stream run program
⍝ and we will get the final:
⍝   1. instruction index (0-relative);
⍝   2. relative base (0-relative, parsed form);
⍝   3. state;
⍝   4. input-stream; and
⍝   5. output-stream.
run ← { ⍝ input-stream run program
  test ← {
    pc state ← ⍺[1 3]
    code ← ⊃state parseCode pc
    ~code∊1 2 3 4 5 6 7 8 9
  }
  program ← ⍵
  input ← ⍺
  output ← ⍬
  step⍣test 0 PZ program input output
}

⍝ fmt¨⊃⌽(⊂parseNum '1') run readProgram day9,'/boost.raw'
⍝ fmt¨⊃⌽(⊂parseNum '2') run readProgram day9,'/boost.raw'
