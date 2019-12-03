split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}

segments ← { ⍝ segments (10 0) (0 ¯5) ...
  corners ← +\(⊂(0 0)),⍵
  d ← +\+/¨|⍵
  h ← ⊃¨2≠/corners
  v ← ~h
  pts ← {
    s ← (⍵,0)/corners
    e ← (0,⍵)/corners
    c ← ≢s
    m ← c 4⍴∊(c 1⍴s),(c 1⍴e)
    5 split∊m,⍵/d
  }
  (pts h) (pts v)
}

contains ← { ⍝ segment-list contains point-matrix
  btwn ← {((⍵[1]⌊⍵[2])≤⍺)∧(⍺≤(⍵[1]⌈⍵[2]))}
  check ← { ⍝ seg pt1 pt2 ... as a vector
    s ← 5↑⍵
    p ← 3 split 5↓⍵
    x ← ({⍵[1]}¨p)btwn(s[1],s[3])
    y ← ({⍵[2]}¨p)btwn(s[2],s[4])
    x∧y
  }
  r ← ≢⍺
  c ← (⍴⍵)[2]
  (⍴⍵)⍴∊check¨(5+3×c)split∊(r 1⍴⍺),⍵
}

dist ← { ⍝ horiz-seg dist vert-seg
  xadj ← |(⍺[3]-⍵[1])
  yadj ← |(⍵[4]-⍺[2])
  (⍺[5]+⍵[5])-(xadj+yadj)
}

points←{ ⍝ horizontal-segments points vertical-segments
  i ← ⍺∘.{(⍵[1])(⍺[2])(⍺ dist ⍵)}⍵
  g ← (⍺ contains i)∧(⍉⍵ contains⍉i)
  (∊g)/,i
}

⍝ To run this, have two wires of the form
⍝   (+X 0) (0 -Y) ...
⍝ (i.e. values along the cartesian axes) and then do
⍝   wire1 run wire2
⍝ and the output will be the distance to the intersection with the combined closest distance.
run ← { ⍝ wire run wire
  sl ← segments ⍺
  sr ← segments ⍵
  pts ← ((⊃sl[1])points(⊃sr[2])),((⊃sr[1])points(⊃sl[2]))
  d ← (⊃⌽)¨pts
  d ← d[⍋d]
  d[1+∧/⊃⍺[1]≠⍵[1]]
}
