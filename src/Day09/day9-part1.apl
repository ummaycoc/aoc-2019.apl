⍝ Reading/parsing an intcode program.
parseProgram←{ ⍝ parseProgram programString
  idx ← (⍵='-')/⍳≢⍵
  prg ← ⍵
  prg[idx] ← ('¯'⍬)[1+0=≢idx]
  (prg≠',')⊆prg
}
readUTF8 ← { ¯1↓1⊃'UTF-8'⎕NGET ⍵ }
readProgram ← { parseProgram readUTF8 ⍵ }

⍝ Parsing an intcode instruction
parseCode ← { ⍝ state parseCode pc
  opcode ← ⍎⌽5↑⌽(1+⍵)⊃⍺
  parsed ← 10 10 10 100⊤opcode
  modes ← ⌽1+3↑parsed
  code ← ⊃¯1↑parsed
  code modes
}

split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}

parseOp ← { ⍝ state parseOp (counter, base) → code (input addrs) (output addrs)
  pc base ← ⍵
  base ← ⍕base
  code modes ← ⍺ parseCode pc
  imm ← pc+⍳3
  pos ← (⍺,3⍴(⊂1⍴'0'))[1+imm]
  rel ← {base add fnum ⍵}¨pos
  idx ← (modes,⍳3)[⍋(⍳3),⍳3]
  addrs ← ⍎¨(↑pos (⍕¨imm) rel)[2 split idx]
  nin ← (2 2 0 1 2 2 2 2 1)[code]
  nout ← (1 1 1 0 0 0 1 1 0)[code]
  ins ← nin↑addrs
  addrs ← nin↓addrs
  outs ← nout↑addrs
  code ins outs
}

⍝ Helper functions to make step independent of representation.
expand ← { ⍝ state expand mems
  max ← ⌈/⍵
  ⍺,(0⌈1+max-≢⍺)⍴⊂1⍴'0'
}

advance ← { ⍝ code res advance pc base inputs outputs
  z ← ⊂1⍴'0'
  code res ← ⍺
  p b ins outs ← ⍵
  next ← p+1+≢ins,outs
  jump ← ⍎2⊃ins,z,z
  zero ← (1⍴'0')≡1⊃ins,z
  jnz ← (next jump)[1+~zero]
  jz ← (next jump)[1+zero]
  p ← (next jnz jz)[1+(code∊5 6)+(code=6)]
  b ← b+((⍎res)×code=9)
  p b
}

compute ← { ⍝ code compute (values, inputs)
  z ← 1⍴'0'
  v i ← ⍵
  ⍺=3: 1⊃i,⊂z
  ⍺∊4 5 6: z
  ⍺=9: 1⊃v
  l r ← v
  ⍺=1: l add fnum r
  ⍺=2: l mul fnum r
  ⍺=7: ⍕l lt snum r
  ⍺=8: ⍕l eq snum r
}

⍝ Program execution
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
⍝   2. relative base (0-relative);
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
  step⍣test 0 0 program input output
}

⍝ If day9 holds the dir for data, and 'boost.raw' is the boost program, try:
⍝ ⊃⌽ (⊂1⍴'1') run readProgram day9,'/boost.raw'
⍝ ⊃⌽ (⊂1⍴'2') run readProgram day9,'/boost.raw'
