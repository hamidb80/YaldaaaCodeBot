import std/[sequtils, strutils, unicode, random, sugar]

# XXX use ARC or ORC"
randomize()

# --- defs

type
  Text = seq[Rune]
  Log = seq[int]

# --- utils

iterator ritems[T](s: openArray[T]): T =
  for i in 1..s.len:
    yield s[^i]

iterator rpairs[T](s: openArray[T]): (int, T) =
  for i in countdown(s.high, 0):
    yield (i, s[i])

func reprLog(r: Log): string =
  for i in r:
    result.add $i
    result.add ' '

func reprLogs*(h: seq[Log]): string =
  h.map(reprLog).join "\n"

# --- core

proc generateLogs(len, number: int): seq[Log] =
  let indexSeq = toseq 0..<len

  for _ in 1..number:
    result.add indexSeq.dup shuffle


func build1(t: Text, pattern: Log): Text =
  result.setLen t.len

  for i, v in pattern:
    result[i] = t[v]

func build(t: Text, logs: seq[Log]): Text =
  result = t

  for pattern in logs:
    result = build1(result, pattern)


func solve1(t: Text, pattern: Log): Text =
  result.setLen t.len

  for i, v in pattern:
    result[v] = t[i]

func solve(final: Text, logs: seq[Log]): Text =
  result = final

  for l in logs.ritems:
    result = solve1(result, l)

func solve*(final: string, logs: seq[Log]): string =
  $solve(final.toRunes, logs)

# --- generate

proc generate(input: Text, logsRange: Slice[int]):
  tuple[shuffled: Text, logs: seq[Log]] =

  let
    logs = generateLogs(input.len, rand logsRange)
    final = build(input, logs)

  (final, logs)

proc generateProblem*(input: string, logsRange: Slice[int]):
  tuple[shuffled: string, logs: seq[Log]] =

  let tmp = generate(input.toRunes, logsRange)
  ($tmp.shuffled, tmp.logs)

# --- example

when isMainModule:
  func wrap(s: string): string =
    '"' & s & '"'

  let
    word = toRunes "شب یلدا"
    history = generateLogs(word.len, 5)
    final = build(word, history)

  echo wrap $word
  echo wrap $final
  echo reprLogs history
  echo "--------------"

  for i, h in history.rpairs:
    echo reprLog h, " -> ", wrap $solve(final, history[i..^1])

