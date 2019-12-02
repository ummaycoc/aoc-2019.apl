step ← {
  p ← ⊃⍵
  s ← ⊃⌽⍵
  o ← s[p+1]
  d ← s[1+s[p+2 3]]
  s[1+s[p+4]] ← ((+/d)(×/d))[o]
  (p+4) s
}

⍝ We can run an intcode program with the following:
⍝   run initialProgram
⍝ So if we set c to be the code from the input
⍝   c ← 1,0,0,3,1,1,2,3,1,...
⍝   c[2 3] ← 12 2
⍝ then we can run this program with
⍝   run c
⍝ and we will get the final instruction index (0-relative) and final state.
run ← {step⍣{~(⊃⌽⍺)[1+⊃⍺]∊1 2}0 ⍵}
