readUTF8 ← { ¯1↓1⊃'UTF-8'⎕NGET ⍵ }

unjoin ← { (~∨⌿↑(1+-⍳≢⍺)∘.⌽⊂⍺⍷⍵)⊆⍵ }

parseReaction ← { ⍝ parseReaction reactionString
  amt ← { q c ← ' ' unjoin ⍵ ⋄ c (⍎q) }
  r p ← ' => ' unjoin ⍵
  r ← ', ' unjoin r
  ↑amt¨(⊂p),r
}

parseRequirements ← { parseReaction¨(⎕UCS 10) unjoin ⍵ }

ore ← { ⍵,(⊂1 2⍴'ORE' 1) }
sort ← { ⍵[⍋⊃¨{⍵[1;1]}¨⍵] }
chems ← { {∪⍵[⍋⍵]}⊃,/{⍵[;1]}¨⍵ }

intern ← {
  ord ← chems ⍵
  idx ← { c←⍵ ⋄ ({c≡⍵}¨ord)⍳1 }
  { ⍉↑(idx¨⍵[;1]) (⍵[;2]) }¨⍵
}

untable ← { r ← ⍺⍴0 ⋄ r[⍵[;1]] ← ⍵[;2] ⋄ r }
matrix ← { n←≢⍵ ⋄ ↑{n untable ⍵}¨1↓¨⍵ }

tops ← { ⍝ tops matrix
  m ← 0≠⍵
  order ← {
    0=≢⍺: ⍵ ⍺
    ⍺ ⍵
  }
  proc ← { ⍝ proc deps cur next out
    deps cur next out ← ⍵
    cur next ← cur order next
    i ← 1⊃cur
    r ← m[i;]
    deps -← r
    deps (1↓cur) (next,((0=deps)∧r)/⍳≢m) (out,i)
  }
  deps ← +⌿m
  first ← 1⍴deps⍳0
  4⊃(proc⍣(≢m)) deps first ⍬ ⍬
}

calcOre ← { ⍝ calcOre interned
  qty ← (⊃,[1]/1↑¨⍵)[;2]
  m ← matrix ⍵
  calc ← { ⍝ calc amts items
    amts items ← ⍵
    next ← ⊃items
    mul ← ⌈amts[next]÷qty[next]
    amts +← mul×m[next;]
    amts[next] ← 0
    (amts) (1↓items)
  }
  ⌈/⊃(calc⍣{0=≢2⊃⍺}) (0=+⌿m) (¯1↓tops m)
}

oreReq ← { calcOre intern sort ore parseRequirements ⍵ }
