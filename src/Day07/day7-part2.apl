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

res ← pc run program;opcodes
  opcodes ← 1 2 5 6 7 8
  :While (100|program[1+pc])∊opcodes
    pc program ← (step pc program ⍬ ⍬)[1 2]
  :EndWhile
  res ← pc program

res ← phases seq program;pc;mem;pcs;ins;lasts;amp;code;codes;temp;next;done
  mem ← {program}¨phases
  pcs ← (≢phases)⍴0
  ins ← {1⍴⍵}¨phases
  ins[1] ← ⊂(1⊃ins),0
  lasts ← (≢phases)⍴0
  amp ← 1
  next ← 1⌽⍳≢phases
  done ← (≢phases)⍴0
  codes ← 1 2 3 4 5 6 7 8 99 ⍝ valid codes
  :While ~¯1↑done
    code ← 100|(amp⊃mem)[1+pcs[amp]]
    :If done[amp]
      amp ← next[amp] ⍝ Maybe this should be an error.
    :ElseIf (code=3)∧(0=≢amp⊃ins) ⍝ No input left, loop
      amp ← next[amp]
    :ElseIf code=99
      done[amp] ← 1
      amp ← next[amp]
    :ElseIf code=3
      pc program ← (step pcs[amp](amp⊃mem)(amp⊃ins)⍬)[1 2]
      pcs[amp] ← pc
      mem[amp] ← ⊂program
      ins[amp] ← ⊂1↓(amp⊃ins)
    :ElseIf code=4
      pc temp ← (step pcs[amp](amp⊃mem)⍬ ⍬)[1 4]
      pcs[amp] ← pc
      lasts[amp] ← 1⊃temp
      ins[next[amp]] ← ⊂((next[amp]⊃ins),1⊃temp)
    :ElseIf code∊codes
      pc program ← (pcs[amp]run amp⊃mem)[1 2]
      pcs[amp] ← pc
      mem[amp] ← ⊂program
    :Else
      ('Unknown code ',⍕code)⎕SIGNAL 200
    :EndIf
  :EndWhile
  res ← ¯1↑lasts

maxamp ← { ⍝ maxamp program
  prg ← ⍵
  amp ← {⍵ seq prg}
  ⌈/amp¨rows perms 4+⍳5
}
