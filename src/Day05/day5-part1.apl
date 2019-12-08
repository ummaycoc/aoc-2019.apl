split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}

parseOp ← { ⍝ state parseOp counter → code (input addrs) (output addrs)
  parsed ← 10 10 10 100⊤⍺[1+⍵]
  modes ← ⌽1+3↑parsed
  code ← ¯1↑parsed
  imm ← ⍵+⍳3
  pos ← ⍺[(1+imm)⌊≢⍺]
  idx ← (modes,⍳3)[⍋(⍳3),⍳3]
  addrs ← (2 3⍴pos,imm)[2 split idx]
  nin ← (2 2 0 1)[code]
  nout ← (1 1 1 0)[code]
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
  output ← ∊o,∊(⍬ ⍬ ⍬ ins)[code]
  res ← ∊((+/ins) (×/ins) (⊃1↑i,0) 0)[code]
  s[∊outs] ← ∊(res res res ⍬)[code]
  (p+1+≢∊ins,outs) s ((code=3)↓i) output
}

⍝ We can run an intcode program with the following:
⍝   input-stream run program
⍝ and we will get the final:
⍝   1. instruction index (0-relative);
⍝   2. state;
⍝   3. input-stream; and
⍝   4. output-stream.
run ← { ⍝ input-stream run program
  test ← {
    pc ← ⊃⍺[1]
    state ← ⊃⍺[2]
    code ← 100|state[1+pc]
    ~code∊1 2 3 4
  }
  program ← ⍵
  input ← ⍺
  output ← ⍬
  step⍣test 0 program input output
}
