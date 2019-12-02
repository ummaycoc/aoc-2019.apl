# December 2019

<pre>
┌─────────────────────────────────────────┐
│  S  │  M  │  T  │  W  │  R  │  F  │  S  │
├─────────────────────────────────────────┤
│  <a href="#day-1">1</a>  │  2  │  3  │  4  │  5  │  6  │  7  │
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

[This Day](#day-1) ◈ [Calendar](#december-2019) ◈ Next Day
