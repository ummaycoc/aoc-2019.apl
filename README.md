# December 2019

<pre>
┌─────────────────────────────────────────┐
│  S  │  M  │  T  │  W  │  R  │  F  │  S  │
├─────────────────────────────────────────┤
│  1  │  2  │  3  │  4  │  5  │  6  │  7  │
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
