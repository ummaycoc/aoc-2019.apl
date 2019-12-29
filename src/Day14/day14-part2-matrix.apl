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

quantity ← { ⍝ quantity interned
  q ← (≢⍵) (≢⍵) ⍴ 0
  (1 1⍉q) ← (⊃,[1]/1↑¨⍵)[;2]
  q
}

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

calcOre ← { ⍝ {amount} calcOre (reactant-matrix quantity-matrix)
  ⍺ ← (≢⊃⍵)⍴0
  initial m qty ← (⊂⍺),⍵
  calc ← { ⍝ calc amts extras items
    amts extras items ← ⍵
    next ← ⊃items
    needed ← 0⌈amts[next]-initial[next]
    extras[next] ← qty[next;next]|-needed
    mul ← ⌈needed÷qty[next;next]
    ((next≠⍳≢m)×amts+mul×m[next;]) (extras) (1↓items)
  }
  ¯1↓(calc⍣{0=≢⊃⌽⍺}) (0=+⌿m) (0×⍺) (¯1↓tops m)
}

melt ← { ⍝ reactant-matrix melt quantity-matrix → melted-matrix
  m qty ← ⍺ ⍵
  order ← ¯1↓tops m
  calc ← { ⍝ calc amts items
    amts items ← ⍵
    next ← ⊃items
    mul ← ⌊amts[next]÷qty[next;next]
    amts[next] ← qty[next;next]|amts[next]
    amts +← mul×m[next;]
    (amts) (1↓items)
  }
  ↑{ ⊃(calc⍣{0=≢⊃⌽⍺})⍵ order }¨↓qty
}

processInfo ← { ⍝ reactant-matrix processInfo quantity-matrix
  melted ← ⍺ melt ⍵
  ordered ← tops ⍺
  oreIdx ← ⊃¯1↑ordered
  oreMask ← oreIdx≠⍳≢⍺
  ordered ← ¯1↓ordered
  oreFuel extra ← calcOre ⍺ ⍵
  oreFuel ← ⌈/oreFuel
  melted ordered oreIdx oreMask oreFuel extra
}

useOre ← { ⍝ ore useOre reactant-matrix quantity-matrix
  reactants qty ← ⍵
  melted ordered oreIdx oreMask oreFuel extra ← reactants processInfo qty
  meltdown ← { ⍝ meltdown amounts items
    amounts items ← ⍵
    next ← ⊃items
    mul ← ⌊amounts[next]÷qty[next;next]
    (qty[next;]|amounts+mul×melted[next;]) (1↓items)
  }
  calc ← { ⍝ calc ore amounts n
    ore amounts n ← ⍵
    q ← ⌊ore÷oreFuel
    amounts ← ⊃(meltdown⍣{0=≢⊃⌽⍺}) (amounts+q×extra) ordered
    (amounts[oreIdx]+oreFuel|ore) (oreMask×amounts) (n+q)
  }
  useExtra ← { ⍝ useExtra ore amounts n
    ore amounts n ← ⍵
    oreLeft newLeft ← amounts calcOre reactants qty
    oreLeft ← ⌈/oreLeft
    ore<oreLeft: ⍵
    (ore-oreLeft) newLeft (n+1)
  }
  (useExtra⍣≡) (calc⍣≡) ⍺ ((≢qty)⍴0) 0
}

consumeOre ← {
  i ← intern sort ore parseRequirements ⍵
  3⊃⍺ useOre (matrix i) (quantity i)
}
