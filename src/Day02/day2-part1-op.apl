step ← {
  s ← ⍵
  o ← s[⍺+1]
  d ← s[1+s[⍺+2 3]]
  s[1+s[⍺+4]] ← ((+/d)(×/d))[o]
  s
}

⍝ We can run an intcode program with the following:
⍝   step run initialProgram
⍝ So if we set c to be the code from the input
⍝   c ← 1,0,0,3,1,1,2,3,1,...
⍝   c[2 3] ← 12 2
⍝ then we can run this program with
⍝   step run c
⍝ and we will get the final instruction index (1-relative) and final state.
res ← (map run) state;p
  p ← 0
  :While state[1+p]∊1 2
    state ← p map state
    p ← p+4
  :EndWhile
  res ← (1+p) state
