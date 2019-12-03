split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}

segments ← { ⍝ segments (10 0) (0 ¯5) ...
  corners ← +\(⊂(0 0)),⍵
  h ← ⊃¨2≠/corners
  v ← ~h
  pts ← {
    s ← (⍵,0)/corners
    e ← (0,⍵)/corners
    c ← ≢s
    4 split∊(c 1⍴s),(c 1⍴e)
  }
  (pts h) (pts v)
}

contains ← { ⍝ segment-list contains point-matrix
  btwn ← {((⍵[1]⌊⍵[2])≤⍺)∧(⍺≤(⍵[1]⌈⍵[2]))}
  check ← { ⍝ seg pt1 pt2 ... as a vector
    s ← 4↑⍵
    p ← 2 split 4↓⍵
    x ← (⊃¨p)btwn(s[1],s[3])
    y ← ((⊃⌽)¨p)btwn(s[2],s[4])
    x∧y
  }
  r ← ≢⍺
  c ← (⍴⍵)[2]
  (⍴⍵)⍴∊check¨(4+2×c)split∊(r 1⍴⍺),⍵
}

points ← { ⍝ horizontal-segments points vertical-segments
  i ← ⍺∘.{(⍵[1])(⍺[2])}⍵
  g ← (⍺ contains i)∧(⍉⍵ contains⍉i)
  (∊g)/,i
}

⍝ To run this, have two wires of the form
⍝   (+X 0) (0 -Y) ...
⍝ (i.e. values along the cartesian axes) and then do
⍝   wire1 run wire2
⍝ and the output will be the Manhattan distance from the origin to the closest intersection.
run ← { ⍝ wire run wire
  sl ← segments ⍺
  sr ← segments ⍵
  pts ← ((⊃sl[1]) points (⊃sr[2])), ((⊃sr[1]) points (⊃sl[2]))
  n ← ≢pts
  d ← +/|(n 2⍴∊pts)
  d ← d[⍋d]
  d[1+∧/⊃⍺[1]≠⍵[1]]
}
