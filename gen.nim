import std/[sequtils, random, sugar, unittest]

randomize()

# --- defs

# TODO use utf-8

# --- utils

iterator ritems[T](s: openArray[T]): T =
  for i in 1..s.len:
    yield s[^i]

# --- core

proc generate(size, n: int): seq[seq[int]] =
  let indexSeq = toseq 0..<size

  for _ in 1..n:
    result.add indexSeq.dup shuffle

func make(sentence: string, records: seq[seq[int]]): string =
  result = sentence

  for r in records:
    var acc = result
    for i, v in r:
      result[i] = acc[v]

func solve(final: string, records: seq[seq[int]]): string =
  result = final

  for r in records.ritems:
    let acc = result
    for i, v in r:
      result[v] = acc[i]

# --- test

suite "tests":
  test "solve 1":
    check solve("ammhin", @[@[3, 0, 2, 1, 5, 4]]) == "mhmani"

  test "solve 2":
    check solve("aimhnm", @[
      @[3, 0, 2, 1, 5, 4],
      @[0, 4, 2, 3, 5, 1]
    ]) == "mhmani"

  test "generate & solve n":
    let
      records = generate("hello".len, 10)
      final = make("hello", records)

    check solve(final, records) == "hello"
