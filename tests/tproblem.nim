import std/[unittest, unicode]
import problem {.all.}

suite "problem generation":
  test "solve 1":
    check solve("ammhin".toRunes, @[@[3, 0, 2, 1, 5, 4]]) == "mhmani".toRunes

  test "solve 2":
    check solve("aimhnm".toRunes, @[
      @[3, 0, 2, 1, 5, 4],
      @[0, 4, 2, 3, 5, 1]
    ]) == "mhmani".toRunes

  test "generate & solve n":
    for _ in 1..10:
      let
        Logs = generateLogs("hello".len, 10)
        final = build("hello".toRunes, Logs)

      check solve(final, Logs) == "hello".toRunes
