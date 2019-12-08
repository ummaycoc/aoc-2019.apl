# December 2019

<pre>
┌─────────────────────────────────────────┐
│  S  │  M  │  T  │  W  │  R  │  F  │  S  │
├─────────────────────────────────────────┤
│  <a href="#day-1">1</a>  │  <a href="#day-2">2</a>  │  <a href="#day-3">3</a>  │  <a href="#day-4">4</a>  │  <a href="#day-5">5</a>  │  6  │  7  │
├─────────────────────────────────────────┤
│  8  │  9  │ 10  │ 11  │ 12  │ 13  │ 14  │
├─────────────────────────────────────────┤
│ 15  │ 16  │ 17  │ 18  │ 19  │ 20  │ 21  │
├─────────────────────────────────────────┤
│ 22  │ 23  │ 24  │ 25  │ 26  │ 27  │ 28  │
├─────────────────────────────────────────┤
│ 29  │ 30  │ 31  │     │     │     │     │
└─────────────────────────────────────────┘
</pre>

# Reading Data

Dyalog provides functionality for reading files on disk. One function, `⎕NGET`, can read the entire contents of a text file with respect to a specified encoding, and that is sufficient for all AoC purposes. The return value has three elements: the content, the encoding used, and the value of the first newline encountered. On OSX, accessing the contents can be done with:
```
fname ← '/path/to/file'
read ← 'UTF-8' ⎕NGET fname
input ← ¯1↓⊃read[1]
```
The drop is usually useful in AoC as it removes the trailing newline from the data. If the data is already in the form of APL data (i.e. an array), then it can be executed with the hydrant symbol `⍎`.

---

# Day 5
## Part One

The solution to this problem will require the `split` function that has already become prolific here:
```
split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}
```

The first significant step, then, is to parse out the next operation from the program. Given the current program memory and a (zero-relative) program counter, this function will return the functional opcode (i.e. 1, 2, 3, or 4) along with the input and output addresses:
```
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
```

The first line of the function has a new symbol, `⊤`, called the down tack. This function will encode the value on the right in the (possibly mixed) radixes on the left. The example displayed in Dyalog is `24 60 60 ⊤ 10000` which encodes 10,000 seconds as 2 days, 46 minutes, and 40 seconds (i.e. the result is `2 46 40`). Here it is used to pick out the actual opcode and the parameter modes. Modes are picked out by using `3↑parsed` to grab the first three elements in `parsed` and since these values will be used as an index they are incremented. `⌽` reverses their order since parameter modes are read right to left. The opcode is the last element in `parsed`, given by `¯1↑parsed`.

As `⍵` is the program counter, `⍵+⍳3` will be the addresses of any of its input/output parameters (assuming there are any), and so these are also the addresses of any parameters in immediate mode. `⍺[(1+imm)⌊≢⍺]` are the values at these positions (`⌊` is the minimum of its left and right arguments, thus there will be no index error here).

Combining the positional and immediate addresses as rows in a matrix, individual elements can be picked out with a nested array of indices (i.e. an array where each item is a vector with a row and column index). This is what `(2 3⍴pos,imm)[2 split idx]` does as `split` yields exactly the type of indexing array needed. `idx` is the interleaving of `modes` and `1 2 3` so that `modes` will select rows and `1 2 3` are column indices. Thus, `addrs` will be the appropriate addresses for given the parameter modes previously parsed out.

`nin` and `nout` describe how many input and output parameters each opcode has and using `↑` and `↓` to manipulate `addrs` the required addresses are stored in `ins` and `outs`.

Now that the information relevant to the next operation can be parsed from the program memory, it's time to write a function to execute a single step of the program:
```
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
```

This function names its args (`p` for program counter, `s` for state, `i` for input-stream, `o` for output-stream) and parses the next command to execute. The addresses used in `ins` are incremented because Dyalog is one-relative and intcode is zero-relative; likewise with `outs`.

`output` appends the any output from the code. It does this by picking out what would be outputted by indexing by `code`; since there is only output when `code` is `4`, all other indices are `⍬`, the empty numerical vector.

To calculate the result to store, all possible values are calculated independent of `code` and the correct one is picked out by indexing and then stored in `s`. Since no data is stored when `code` is `4`, again the emtpy vector is used.

Finally the returned program counter is returned--advanced by 1 to account for the consumed program counter and then by the count of all parameters, both in and out. The input stream is advanced if it was used.

Bringing it all together, the following function will run an intcode program:
```
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
```

This uses the `power` operator to calculate a fixpoint via the `test` function above, and is straight forward.

## Part Two

The solution to part two involves some minor changes and one substantial but not overwhelming change. In `parseOp` the lines calculating `nin` and `nout` become:
```
  nin ← (2 2 0 1 2 2 2 2)[code]
  nout ← (1 1 1 0 0 0 1 1)[code]
```
to reflect the new instructions. In `run` the last line of the `test` function becomes
```
    ~code∊1 2 3 4 5 6 7 8
```
to reflect the new instructions' op codes.

The bulk of the changes, obviously, are in the `step` function as this handles actual logic. The function now looks like:
```
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
```
Every lines from when `output` is assigned is either new or has changed. The assignments to `output`, `res`, and `s[∊outs]` have changed in simple ways to reflect the new commands. The change on the last line merely reflects that the program counter being returned is calculated a few lines earlier.

The other lines, from the assignment to `next` down to the assignment to `p`, involve calculating the program counter in the presence of possible jumps. `next` is what the program counter will be in the absence of a jump and `jump` stores the address of the jump destination when present. `zero` tests if the first parameter is zero or not. When `zero` is true, `jnz` is just `next` and `jz` will be set to `jump`; when `zero` is false, the roles are switched. Finally, the program counter is picked out of an array based on the current opcode.

* [Day 5, Part 1](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day05/day5-part1.apl).
* [Day 5, Part 2](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day05/day5-part2.apl).

[This Day](#day-5) ◈ [Calendar](#december-2019) ◈ Next Day

# Day 4
## Part One

Call a number that meets the stated criteria _admissible_ and note that the set {353,096, …, 843,212} (my input range, yours is likely different) can be written as: ({353,096, …, 355,554} ∪ {355,555, …, 399,999} ∪ {400,000, …, 444,443} ∪ {444,444, …, 999,999}) ∖ ({843,213, …, 888,887} ∪ {888,888, …, 999,999}). There are no numbers in the sets {353,096, …, 355,554}, {400,000, …, 444,443}, {843,213, …, 888,887} with a non-decreasing digit sequence, and so the set of admissible numbers between 353,096 and 843,212 can be written as ({355,555, …, 399,999} ∪ {444,444, …, 999,999}) ∖ {888,888, …, 999,999}. 

To count the number of admissible numbers in the first set, {355,555, …, 399,999}, notice that the last five digits must be chosen from the set {5, 6, 7, 8, 9} and can be chosen with replacement. Choice here is in the n choose k sense (i.e. counting / permutations / binomial coefficients). If (n k) denotes n choose k, then ((n+k-1) k) is the formula for choosing k items from a set of n elements with replacement. Any choice represents a specific selection--say for example that the five choices are 5, 6, 6, 7, and 8 then the selected number is 356,678. The only invalid choices are those without numbers repeated, which can be counted just as (n k).

Likewise, to count the second set one must choose six digits from {4, 5, 6, 7, 8, 9} and similarly remove choices without repetition.

Finally counting the last set involves choosing six digits from {8, 9}; since all of these have repeated digits (pigeon hole principle), no subtraction must be made to counter balance earler subtractions.

In APL, (n k) is written `k!n` and so this problem's solution is
```
((5!5+5-1) + (6!6+6-1)) - ((5!5) + (6!6) + (6!6+2-1))
```

## Part Two

For part two the same three sets will be used to compute the final value with the new admissibility criteria. The set {355,555, …, 399,999}'s admissible values can be found by choosing which of the five digits we want to be expressed _exactly_ twice (there are obviously five options). After this choice there are three positions left with four digits to select to fill them with using replacement, so the initial count for this set is 5 * ((3+4-1) 3).

But some choices are double counted in this method (such as 355,667, counted for both the choice of 5 and 6 as the explicitly doubled digit). The number of times such a choice is double counted can be calculated as follows: for five spaces, we choose _two_ digits to explicitly double and then have three choices for the remaining digit, so 3 * (5 2) must be subtracted from the initial count.

Considering the set {444,444, …, 999,999} and following the same logic there are six choices of numbers to explicitly double with four spaces left to be filled by five digits to be chosen with replacement, giving an initial count of 6 * ((4+5-1) 4).

The number of double counted values with exactly two digits counted as being explicitly doubled is given by (6 2) * (4 2) since there are six digits to choose the two doubled digits and there are four choices to select the remaining two digits. Additionally, there can be triple counted values, and for six possibilities selecting three values gives (6 3), but each is counted three times so 2 * (6 3) must be subtracted.

Finally, {888,888, …, 999,999} only has two admissible values: {888,899, 889,999}. Writing this all in APL gives:
```
((5×3!3+4-1) + (6×4!4+5-1)) - ((3×2!5) + ((2!6)×(2!4)) + (2×3!6) + 2)
```

Note that if in calculating the double count in the second set the remaining two digits were allowed to also be the same--i.e. instead of (6 2) * (4 2) use (6 2) * ((4+2-1) 2)--then by the principle of inclusion exclusion the triple counted values must be added instead of doubled and subtracted.
```
((5×3!3+4-1) + (6×4!4+5-1) + (3!6)) - ((3×2!5) + ((2!6)×(2!4+2-1)) + 2)
```

[This Day](#day-4) ◈ [Calendar](#december-2019) ◈ [Next Day](#day-5)

# Day 3
## Part One

As a preliminary step, the following function is defined:
```
split ← {(0=⍺|¯1+⍳≢⍵)⊂⍵}
```
which is a solution to the first problem in the [2019 Dyalog Student Competition](https://www.dyalog.com/student-competition.htm). What this function does is split a vector into equal sized chunks with possibly a short last element. Thus `3 split ⍳5` would give a nested array with `1 2 3` followed by `4 5`. This works by using the partition function `⊂` which splits up an array on the right based on where it finds ones on the left. So `0 1 0 ⊂ 1 2 3` would yield `2 3` (it starts "collecting" a new group whenever it sees a `1`) and `1 0 0 ⊂ 1 2 3` would yield `1 2 3`, both examples yielding a nested array of length one. Likewise `1 0 1 0 ⊂ 1 2 3 4` would yield a nested array of two elements, the first being `1 2` and the second being `3 4`.

The partition mask is calculated with `(0=⍺|¯1+⍳≢⍵)` where `≢` is the tally function which counts the number of elements a vector has, and so if the righthand argument has 5 elements then `¯1+⍳≢⍵` will be the vector `0 1 2 3 4`. `|` when given both a left and righthand argument is the modulus operator, like `%` in Java, C, etc. The lefthand argument here is the function's lefthand argument `⍺` and the mask is calculated as where this modulus is equal to `0`, so if `⍵` has `9` elements and `4` is given as a lefthand argument, then the mask `0=⍺|¯1+⍳≢⍵` would be `0=4|0 1 2 3 4 5 6 7 8 9` or `1 0 0 0 1 0 0 0 1 0` and `⍵` would be split into three groups -- its first four elements, it's next four, and it's final element.

Assume then that the instructions (such as L10, U5, etc) have been processed such that `L10` becomes `¯10 0` and so these are translated into "cartesian" commands. These directions can be turned into the collection of horizontal and vertical line segments which form the wire via:
```
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
```

The above introduces the following new ideas:
* _Scan:_ Just as `/` is a collapsing reduce, `\` is a scan, that is a reduction that stores all the intermediate steps in the result so that `+\1 2 3` is `1 3 6`.
* _Windowed Reduction:_ `2≠/corners` takes a sliding window of two corners and compares them.
* _Compression:_ `pts` twice uses `binary-vector / vector` where both sides of `/` have the same length, and what this does is pick out the elements on the right where there appears a one on the left.
* _Enclose:_ `⊂ value` will _nest_ value as an item in an array, so `⊂ 1 2 3` is a nested array of one element, and that element has three numbers.
* _Reshape:_ `integers ⍴ vector` will reshape the vector on the right to have the shape on the left, so `r c ⍴ 0` would be a `r` by `c` zero matrix (values are cycled).

Now that all the new material is described, the function can be detailed. Given a sequence of directions, such as `(8 0) (0 5) (¯5 0) (0 ¯3)` in the first example on the problem page, corners will be `(0 0) (8 0) (8 5) (3 5) (3 2)`. By construction (and the assumption that the input is a vector of movements parallel to the axes) every pair of adjacent corners differ only in one coordinate. `h` does a windowed reduction to find those pairs where the x coordinate differs (and hence the y coordinate does not). That is `h` finds the horizontal segments, creating a boolean vector by using `⊃¨` to pick out the first element of the comparison. Since a segment is either horizontal or vertical, `v` is the vertical segments.

`pts` takes a binary vector and splits corners into a set of adjacent points that start at the selected points and end at the next point. `segments` uses `pts` to find both the horizontal and vertical segments, returning a two element nested array where the first element has a nested array of horizontal segments and the second element has the vertical ones. Example: `segments (8 0) (0 5) (¯5 0) (0 ¯3)` yields an array where the first element is `(0 0 8 0)  (8 5 3 5)` and the second is `(8 0 8 5) (3 5 3 2)`.

Now that segments can be calculated the next step is to write a function where a matrix of points (i.e. every element is itself an array of two integers) and a list of segments are compared and returns a binary matrix denoting when the points appear in the segments, with the nth segment associated with the nth row:
```
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
```
This function is straight forward:
* First note that `⍴` when given a lefthand argument reshapes its righthand argument, but when given no lefthand argument it returns the shape of the righthand argument.
* `↑` and `↓` are called take and drop, respectively, and they either take elements or drop elemens from their righthand argument. If the lefthand argument is positive, they act on the front of the list, if it is negative they act on the end (so `¯1↑v` is the last element of `v`).
* `b btwn a c` will return true if `b` is between `a` and `c`; note that `b` does not have to be a scalar but `a` and `c` should be the same _shape_ as `b` (more specifically, any of them that are nonscalars must agree on shape). Thus `1 2 3 4 5 6 btwn 3 4` would yield `0 0 1 1 0 0`.
* `check` assumes that it is given a vector where the first four elements are the (x, y) coordinates of a segment's endpoints and the rest of the vector is a series of points to check if they belong in that segment. First the function checks if the `x` coordinates are in the segment, then the `y` coordinates, then uses `∧` to and those two boolean vectors.
* `r` is the number of number of segments given in the lefthand argument (which should be the number of rows in the righthand argument) and `c` is the number of columns in the righthand argument (the point matrix).
* The final line prepends every segment to its associated row with `(r 1⍴⍺),⍵`, and `∊` flattens this into a single vector which is then turned into a nested array of vectors with `split`, each of which is passed to `check`. The results are gathered and flattened with `∊` and given the shape of the point matrix (the righthand argument).

Getting close to the finish line, the next function will take a list of horizontal segments and a list of vertical segments and find where they intersect:
```
points ← { ⍝ horizontal-segments points vertical-segments
  i ← ⍺∘.{(⍵[1])(⍺[2])}⍵
  g ← (⍺ contains i)∧(⍉⍵ contains⍉i)
  (∊g)/,i
}
```

Such a small function, but such a good one, too. The first line uses `∘.f` to create a times table based on `f`--`∘.` is the outer product operator. For every element on the left (here the horizontal segments) and every element on the right (here the vertical segments), `∘.f` calculates `f` on each pair and places the result in a matrix at what would be the corresponding row and column if this was a times table. The `f` above takes the `x` coordinate of a vertical segment and the `y` coordinate of a horizontal one, yielding a potential list of intersection points between a horizontal and vertical segment.

This is the point matrix that will be passed to `contains`. In calculating `g` first find what horizontal segments contain points in `i` and then find which vertical segments contain points in `i` and use `∧` to find where both situations occur. In finding the vertical segments the point matrix is transposed with `⍉` as the vertical segments are associated with columns, the result of the second `contains` is then transposed again so that both sides of `∧` are in the same logical domain.

Finally, `g` is flattend with `∊` and compresses `,i` (`,i` turns the matrix `i` into a vector of its elements). This is the value returned.

Bringing it all together, the intersection of two wires can be found with:
```
run ← { ⍝ wire run wire
  sl ← segments ⍺
  sr ← segments ⍵
  pts ← ((⊃sl[1]) points (⊃sr[2])), ((⊃sr[1]) points (⊃sl[2]))
  n ← ≢pts
  d ← +/|(n 2⍴∊pts)
  d ← d[⍋d]
  d[1+∧/⊃⍺[1]≠⍵[1]]
}
```

`sl[1]` is the first element of the segments of the left wire and `⊃sl[1]` unwraps it from being a singleton containing an array. Intersections are gathered with the horizontal segments of one wire and the vertical segments of the other. The distance of each intersection is calculated with `+/|(n 2⍴∊pts)` which places all the points together in two column matrix and adds the absolute value (`|`) of each column to get the manhattan distance.

`⍋` is called grade up and `⍋ vector` yields a vector of indices that would sort `vector` in ascending order. Given how intersections are calculated, the origin is guaranteed to be the first closest intersection when the two wires start off along different axes, and `∧/⊃⍺[1]≠⍵[1]` accounts for this by checking if the initial movement disagrees on both axes, if so the second smallest distance is returned, else the first.

## Part Two
Part two uses the same `split` function as before but starts changing things in the `segments` code:
```
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
```

Here the change is that `d`, the total distance traveled on the wire when reaching the end of a given segment, is calculated and added as the fifth item of each segment vector, and so segments are now of the form `start-x, start-y, end-x, end-y, origin-to-end-distance`.

Since the size of a segment's representation changed the `contains` function which relies on such data must as well:

```
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
```
The difference being that some `4`s changed to `5`s and some `2`s changed to `3`s. The `5`s we understand from above, but the `3`s occur because the values in the point matrix will no longer be just x, y coordinates but also have a third value--the combined distance of both wires to that specific point (i.e. the value to be minimized across feasible intersections). The only other change is accessing these values in getting `x` and `y` inside `check`.

A helper function `dist` calculates the above referenced combined distance from the origin for a horizontal and vertical segment:
```
dist ← { ⍝ horiz-seg dist vert-seg
  xadj ← |(⍺[3]-⍵[1])
  yadj ← |(⍵[4]-⍺[2])
  (⍺[5]+⍵[5])-(xadj+yadj)
}
```
`xadj` is how much the horizontal segment's distance total overshoots its wires contribution since the intersection can happen inside the segment. `yadj` likewise is the overshoot of the vertical segment's distance total. The return value is the sum of the distance along each segment's wire to those segment's endpoints minus the combined overshoots.

```
points←{ ⍝ horizontal-segments points vertical-segments
  i ← ⍺∘.{(⍵[1])(⍺[2])(⍺ dist ⍵)}⍵
  g ← (⍺ contains i)∧(⍉⍵ contains⍉i)
  (∊g)/,i
}
```
The change to `points` is simple: it places the calculated distance to each intersection point into the returned point matrix.

```
run ← { ⍝ wire run wire
  sl ← segments ⍺
  sr ← segments ⍵
  pts ← ((⊃sl[1]) points (⊃sr[2])), ((⊃sr[1]) points (⊃sl[2]))
  d ← (⊃⌽)¨pts
  d ← d[⍋d]
  d[1+∧/⊃⍺[1]≠⍵[1]]
}
```
Finally `run` brings it all together by stripping out the calculated distances from intersection points and finding the first one that is not just starting at the origin (for when wires start off in separate directions).

* [Day 3, Part 1](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day03/day3-part1.apl).
* [Day 3, Part 2](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day03/day3-part2.apl).

[This Day](#day-3) ◈ [Calendar](#december-2019) ◈ [Next Day](#day-4)

# Day 2
## Part One

The first step of part one of day 2 is to define a function to take a step in an intcode program; the following direct function does this:
```
step ← {
  s ← ⍵
  o ← s[⍺+1]
  d ← s[1+s[⍺+2 3]]
  s[1+s[⍺+4]] ← ((+/d)(×/d))[o]
  s
}
```

The above is all rather straight forward--`s` stores the righthand argument, which should be the program state. The lefthand argument denotes the program counter--i.e. the position of the opcode, the value of which is stored in `o`. The operands to the opcode are stored in `d` and on the next line the state `s` is updated with either the sum or the product of those values. Finally, the final state `s` is returned.

The execution of a program will be handled by a user define operator (a piece of code that derives a new function based on an old function):
```
res ← (map run) state;p
  p ← 0
  :While state[1+p]∊1 2
    state ← p map state
    p ← p+4
  :EndWhile
  res ← (1+p) state
```

The operator `run` takes a function `map` to yield a function that accepts an initial `state`. The derived function will use `map` to transition by executing a step of the program (hint: it will be the `step` function above). The program starts at position zero and the state is updated as long as the opcode is either `1` or `2`. The final state and position are returned.

Additionally, this can be solved with the power operator (which did the fixed point calculation from day 1). First `step` needs to return a new position and a new state, and its righthand argument will be the position and state so that it maps between the same domain:
```
step ← {
  p ← ⊃⍵
  s ← ⊃⌽⍵
  o ← s[p+1]
  d ← s[1+s[p+2 3]]
  s[1+s[p+4]] ← ((+/d)(×/d))[o]
  (p+4) s
}
```
and the stopping condition is just the negation of the while loop condition above:
```
{step⍣{~(⊃⌽⍺)[1+⊃⍺]∊1 2}0 ⍵}
```

## Part Two

Creating a new direct function that calculates a new final position / final state pair based on a noun / verb pair yields the following:
```
nv ← {
  step ← {
    p ← ⊃⍵
    s ← ⊃⌽⍵
    o ← s[p+1]
    d ← s[1+s[p+2 3]]
    s[1+s[p+4]] ← ((+/d)(×/d))[o]
    (p+4) s
  }
  state ← 1 (⊃⍵) (⊃⌽⍵) 3 1 1 2 3 ⍝ ... rest of intcode; cut short for formatting
  step⍣{~(⊃⌽⍺)[1+⊃⍺]∊1 2} 0 state
}
```

The result can be found by applying this to every pair of integers between 0 and 99; a list of those pairs can be generated by:
```
nvs ← ,(¯1)+⍳100 100
```
which creates all the indices of a 100 x 100 matrix and subtracts 1 from those indices; the `,` changes the table into a vector. Using the each operator `¨` (map in other languages) `nv` can be applied to every element of `nvs`:
```
nv¨nvs
```
Applying the each operator again to pick out the output of the results gives
```
{(⊃⌽⍵)[1]}¨nv¨nvs
```
The desired output `19690720` can be found with the index of function
```
({(⊃⌽⍵)[1]}¨nv¨nvs)⍳19690720
```
however note that indexing is one-relative in Dyalog, so if our table of indices was
```
 0  0    0  1 ...  0 99
 1  0    1  1 ...  1 99
99  0   99  1 ... 99 99
```
which unraveled would be
```
0 0   0 1 ... 99 99
```
the index of the item at row, say, 5 (i.e. `noun` equal to `4`) and column 88 (i.e. `verb` equal to `87`) would be 488, as it would be the 488th element, but `4*100 + 87 = 487` and so the actual solution to the problem is:
```
(¯1)+({(⊃⌽⍵)[1]}¨nv¨nvs)⍳19690720
```

* [Day 2, Part 1](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day02/day2-part1-op.apl) (Using a User Defined Operator).
* [Day 2, Part 1](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day02/day2-part1-power.apl) (Using `⍣` power).
* [Day 2, Part 2](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day02/day2-part2.apl).

[This Day](#day-2) ◈ [Calendar](#december-2019) ◈ [Next Day](#day-3)

# Day 1
## Part One

As I mentioned in my [first post using APL](https://ummaycoc.github.io/wc.apl/), `{` and `}` introduce a direct function with `⍵` its righthand argument. The first part of the first problem can be calculated with the direct function:
```
{+/(¯2)+⌊⍵÷3}
```

`+/` is a fold/reduce to sum up an array of values, so `+/ 1 2 3` is `6`. The array of values to be summed is given by `(¯2)+⌊⍵÷3`--it's perfectly fine to read this left to right but most of the time it can be easier to read APL from right to left. In that regard:
* `⍵÷3` divides each element of the direct function's righthand input by `3`, so `10, 11, 12` would become `3.333333 3.6666667 4` (or such).
* `⌊` is the flooring function and is applied to each element, so `10 11 12` applied to `⌊⍵÷3` would yield `3 3 4`.
* `(¯2)+` just subtracts `2` from each element and so `10 11 12` now becomes `1 1 2` when applied to `(¯2)+⌊⍵÷3`.

## Part Two
The second part of the problem can be solved by calculating a fixed point of a function. First, define the following function which takes a vector where the first element represents the _next_ mass to calculate fuel for and the last element represents the total fuel calculated so far:
```
fuel ← { ⍝ (next-mass, sum-so-far)
  e ← 0⌈(¯2)+⌊(⊃⍵)÷3
  e (e+⊃⌽⍵)
}
```
A lot of this is similar to the above. The new symbols are:
* `←` is merely assignment.
* `⍝` starts a `//`-style comment.
* `⌈` when applied to one argument is the ceiling function, but when applied to two (as it is here) it is the maximum function.
* `⊃` gives the first item out of an array.
* `⌽` reverses an array.
* Note that `⊃⌽` will give the last item of an array.

And so what the `fuel` function does is calculate the fuel needed to move the mass given by fuel's first righthand argument (or zero if the result is negative) and stores this in `e`. A direct function's return value is the first "unused" expression and so `fuel` will return a two element vector--the fuel needed to move the mass described in the first righthand argument and then that value added to the last righthand argument.

As you might be able to tell, this is just calculating one iteration of a loop. The function is given the "next" amount of mass to calculate fuel for along with the amount calculated so far and returns the amount of fuel needed for the "next" amount together with an updated total. This process should iterate until there is no more fuel necessary (i.e. `e` is zero). This can be accomplished with the following direct function:
```
total ← {⊃⌽(fuel⍣{⊃⍺=⍵}) ⍵ 0}
```

The only new symbols here are `=` which is equality and `⍣` which, in this context, iterates a computation on a value until a condition is met (i.e. it is a loop). The stop condition is given by the direct function `{⊃⍺=⍵}` which will compare the newly calculated value `⍺` against the an old value `⍵`; since the state consists of two numbers ("next" mass and sum so far), `⍺=⍵` is a length two vector of booleans, which is one boolean too many. `⊃` ensures that only the first one is used (both should be the same).

So `(fuel⍣{⊃⍺=⍵})` will repeatedly apply `fuel` to some righthand argument until the result no longer changes. That initial value is `⍵ 0`--the initial mass (and righthand argument of total) along with an initial sum so far of zero. Applying `⊃⌽` picks out the final sum.

Finally, the total fuel needed can be calculated using the each operator `¨` which applies a function on its left to every element of the array on its right. Together with a summing reduce `+/` the overall fuel total for all modules in an input vector can be calculated with the direct function:
```
{+/total¨⍵}
```

The code can be a bit more array oriented by noting that fuel and can work on more than one item at a time. Changing fuel to be
```
fuel ← { ⍝ first row is next mass, second row is fuel so far
  e ← 0⌈(¯2)+⌊(⍵[1;])÷3
  (⍴⍵)⍴∊e(e+⍵[2;])
}
```
and now the calculations for the fuel needed for every module is done all at once as `⍵[1;]` is a _row_ of masses to calculate fuel for and `⍵[2;]` is a _row_ of fuel added so far). Updating the total function results in:
```
total ← {+/∊(fuel⍣{∧/∊⍺=⍵})(∊2(⍴⍵))⍴(⍵,(⍴⍵)⍴0)}
```
taking the input of module masses and making them the first row in a matrix and letting the second row (the fuel added so far) start at all `0`s. This is what `(∊2(⍴⍵))⍴(⍵,(⍴⍵)⍴0)` does, with `∊` flattening the dimensions into a vector. The only other change here is the stopping condition--now the old and new value are checked for equality in every position. `+/∊` adds up everything in the final result.

* [Day 1, Part 1](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day01/day1-part1.apl).
* [Day 1, Part 2](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day01/day1-part2-each.apl) (Using `¨` each).
* [Day 1, Part 2](https://github.com/ummaycoc/aoc-2019.apl/blob/master/src/Day01/day1-part2-array.apl) (Using array operations).

[This Day](#day-1) ◈ [Calendar](#december-2019) ◈ [Next Day](#day-2)
