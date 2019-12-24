⍝ Use the intcode computer from before, but uses just step not run

intcode ← {
  ⍝ (program) (onInput intcode onOutput) (initial-state) → (pc base program) (final-state)
  ⍝ pc base program onInput state → input' state'
  ⍝   is executed _before_ step, of course
  ⍝ pc base program onOutput (state output) → state'
  ⍝   is executed _after_ step, of course
  getCode ← { ⊃(3⊃⍵) parseCode (1⊃⍵) }
  notIO ← { ~(getCode ⍺)∊(⍳9)~3 4 }
  notHalt ← { ~(getCode 1⊃⍺)∊⍳9 }
  processIn ← ⍺⍺
  processOut ← ⍵⍵
  onInput ← { ⍝ (pc base program) (callback onInput) (state) → (pc base program) (state)
    input state ← ⍺ processIn ⍵
    (step (⍺,(⊂input)⍬))[1 2 3] state
  }
  onOutput ← { ⍝ (pc base program) (callback onOutput) (state) → (pc base program) (state)
    res ← step (⍺,⍬ ⍬)
    state ← (res[1 2 3]) processOut (⍵ (5⊃res))
    (res[1 2 3]) state
  }
  exec ← { ⍝ exec (pc base program) (state)
    intstate state ← ⍵
    code ← ⊃(3⊃intstate) parseCode (1⊃intstate)
    3=code: intstate onInput state
    4=code: intstate onOutput state
    ((step⍣notIO) intstate,⍬ ⍬)[1 2 3] state
  }
  (exec⍣notHalt) (0 PZ ⍺) ⍵
}

ioIn ← { ⍝ (pc base program) ioIn (blocks ball paddle output score)
  bx px ← 9○⍵[2 3]
  (parseNum ⍕ (-bx<px)+(bx>px)) ⍵
}

ioOut ← { ⍝ (pc base program) ioOut (state output)
  (blocks ball paddle outs score) new ← ⍵
  outs ,← fmtInt¨new
  3>≢outs: blocks ball paddle outs score
  x y tile←outs
  pos←x+y×0J1
  pos=¯1: blocks ball paddle ⍬ tile
  1=tile: blocks ball paddle ⍬ score
  2=tile: (∪blocks,pos)ball paddle ⍬ score
  3=tile: blocks ball pos ⍬ score
  4=tile: blocks pos paddle ⍬ score
  (blocks~pos) ball paddle ⍬ score
}

run ← { ⍝ run program-string
  program ← parseProgram program
  program[1] ← ⊂parseNum'2'
  2 5⊃program (ioIn intcode ioOut) ⍬ ¯1J¯1 ¯1J¯1 ⍬ 0
}
