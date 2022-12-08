import std/[sequtils, strutils, unicode, random, sugar, unittest]

randomize()

when compileOption("mm", "refc"):
  {.fatal: "use ARC or ORC".}

# --- defs

type
  Text = seq[Rune]
  Record = seq[int]
  History = seq[Record]

# --- utils

iterator ritems[T](s: openArray[T]): T =
  for i in 1..s.len:
    yield s[^i]

iterator rpairs[T](s: openArray[T]): (int, T) =
  for i in countdown(s.high, 0):
    yield (i, s[i])

func toLog(r: Record): string =
  for i in r:
    result.add $i
    result.add ' '

func toLogs(h: History): string =
  h.map(toLog).join "\n"

func wrap(s: string): string =
  '"' & s & '"'

# --- core

proc genHistory(len, number: int): History =
  let indexSeq = toseq 0..<len

  for _ in 1..number:
    result.add indexSeq.dup shuffle


func build1(t: Text, rec: Record): Text = 
  result.setLen t.len
  
  for i, v in rec:
    result[i] = t[v]

func build(t: Text, records: History): Text =
  result = t

  for r in records:
    result = build1(result, r)
    

func solve1(t: Text, rec: Record): Text = 
  result.setLen t.len

  for i, v in rec:
    result[v] = t[i]

func solve(final: Text, records: History): Text =
  result = final

  for r in records.ritems:
    result = solve1(result, r)

# --- test

suite "tests":
  test "solve 1":
    check solve("ammhin".toRunes, @[@[3, 0, 2, 1, 5, 4]]) == "mhmani".toRunes

  test "solve 2":
    check solve("aimhnm".toRunes, @[
      @[3, 0, 2, 1, 5, 4],
      @[0, 4, 2, 3, 5, 1]
    ]) == "mhmani".toRunes

  test "generate & solve n":
    let
      records = genHistory("hello".len, 10)
      final = build("hello".toRunes, records)

    check solve(final, records) == "hello".toRunes


when isMainModule:
  let
    word = toRunes "شب یلدا"
    history = genHistory(word.len, 5)
    final = build(word, history)

  echo wrap $word
  echo wrap $final
  echo toLogs history
  echo "--------------"

  for i, h in history.rpairs:
    echo toLog h, " -> ", wrap $solve(final, history[i..^1])
