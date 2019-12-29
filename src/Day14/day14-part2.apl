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

calcOre ← { ⍝ {amount} calcOre interned
  ⍺ ← (≢⍵)⍴0
  initial ← ⍺
  qty ← (⊃,[1]/1↑¨⍵)[;2]
  m ← matrix ⍵
  calc ← { ⍝ calc amts extras items
    amts extras items ← ⍵
    next ← ⊃items
    needed ← 0⌈amts[next]-initial[next]
    extras[next] ← qty[next]|-needed
    mul ← ⌈needed÷qty[next]
    amts +← mul×m[next;]
    amts[next] ← 0
    (amts) (extras) (1↓items)
  }
  ¯1↓(calc⍣{0=≢⊃⌽⍺}) (0=+⌿m) ((≢⍵)⍴0) (¯1↓tops m)
}

melt ← { ⍝ amounts melt interned
  qty ← (⊃,[1]/1↑¨⍵)[;2]
  m ← matrix ⍵
  calc ← { ⍝ calc amts items
    amts items ← ⍵
    next ← ⊃items
    mul ← ⌊amts[next]÷qty[next]
    amts[next] ← qty[next]|amts[next]
    amts +← mul×m[next;]
    (amts) (1↓items)
  }
  ⊃(calc⍣{0=≢⊃⌽⍺}) ⍺ (¯1↓tops m)
}

processInfo ← { ⍝ processInfo interned
  data ← ⍵
  qty ← (⊃,[1]/1↑¨data)[;2]
  m ← matrix data
  mod ← ↑qty×↓{⍵ ⍵⍴(1,(⍵⍴0))}≢m
  melted ← ↑{⍵ melt data}¨↓mod
  ordered ← tops m
  oreIdx ← ⊃¯1↑ordered
  oreMask ← oreIdx≠⍳≢m
  ordered ← ¯1↓ordered
  oreFuel extra ← calcOre data
  oreFuel ← ⌈/oreFuel
  qty mod melted ordered oreIdx oreMask oreFuel extra
}

useOre ← { ⍝ ore useOre interned
  qty mod melted ordered oreIdx oreMask oreFuel extra←processInfo ⍵
  meltdown ← { ⍝ meltdown amounts items
    amounts items ← ⍵
    next ← ⊃items
    mul ← ⌊amounts[next]÷qty[next]
    (mod[next;]|amounts+mul×melted[next;]) (1↓items)
  }
  calc ← { ⍝ calc ore amounts n
    ore amounts n ← ⍵
    q ← ⌊ore÷oreFuel
    amounts ← ⊃(meltdown⍣{0=≢⊃⌽⍺}) (amounts+q×extra) ordered
    (amounts[oreIdx]+oreFuel|ore) (oreMask×amounts) (n+q)
  }
  useExtra ← { ⍝ useExtra ore amounts n
    ore amounts n ← ⍵
    oreLeft newLeft ← amounts calcOre ⍺
    oreLeft ← ⌈/oreLeft
    ore<oreLeft: ⍵
    (ore-oreLeft) newLeft (n+1)
  }
  ⍵ (useExtra⍣≡) (calc⍣≡) ⍺ ((≢⍵)⍴0) 0
}

consumeOre ← { 3⊃⍺ useOre intern sort ore parseRequirements ⍵ }
