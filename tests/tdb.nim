import std/[unittest, os, times, options]
import norm/[model, sqlite]
import database {.all.}

# --- utils

func `{}`(us: seq[User], id: int): User =
  for u in us:
    if u.chatid == id:
      return u

template `?`(s): untyped = some s
template `!`(t): untyped = none t

# --- generators

func u(c: int64, u, f, l: string, s: UserState): User =
  User(
    chatid: c,
    username: u,
    firstname: f,
    lastname: l,
    state: s)

proc p(id: int, poet: string, u: Option[User]): Puzzle =
  result = genPuzzle poet
  result.id = id
  result.belongs = u

func a(u: User, t: DateTime, s: bool): Attempt =
  Attempt(user: u, timestamp: t, succeed: s)

# --- sample data

var
  users = @[
    u(11, "hamidb80", "hamid", "bluri", usProblem),
    u(12, "MHB80", "hassan", "barati", usWon),
    u(13, "helloworlddev", "behnia", "soleimani", usAnswer),
    u(14, "Amir_H7", "amirhossein", "nezafati", usProblem),
    u(15, "amirreza_tav", "amirreza", "tavakolo", usProblem),
  ]

  puzzles = @[
    p(1, "Hello", ?users{11}),
    p(2, "I Love You", ?users{12}),
    p(3, "the way", ?users{13}),
    p(4, "you are", !User),
  ]

  attempts = @[
    a(users{11}, now(), false),
    a(users{11}, now(), false),

    a(users{12}, now(), false),
    a(users{12}, now(), false),
    a(users{12}, now(), false),
    a(users{12}, now(), true),

    a(users{13}, now(), true),
  ]

# --- tests
import logging
var consoleLog = newConsoleLogger()
addHandler(consoleLog)

suite "DataBase":
  const path = "./test.db"
  
  if fileExists path: 
    removeFile path
  
  putEnv("DB_HOST", path)
  createDB()

  template ins(what): untyped =
    for i in what.mitems:
      || db.insert(i, force = true)

  test "insert":
    ins users
    ins puzzles
    ins attempts

  test "change user state":
    update users{11}, usWon
    check getUser(11).state == usWon

  test "add user":
    discard addUser(16, "sinaMaleki11", "sina", "maleki")
    check getUser(16).firstName == "sina"

  test "add or get user":
    let u = addOrGetUser(11, "aliii", "jamshid", "reza")
    check:
      u.username != "aliii"
      getUser(11).username == "hamidb80"

  test "get free puzzle":
    var p = getFreePuzzle()
    p.belongs = some users{15}
    update p
    check p.id == 4

    expect NotFoundError:
      discard getFreePuzzle()

  test "get user's puzzle":
    let p = getUserPuzzle(users{12})

    check:
      p.belongs.get.chatid == 12
      p.id == 2

  test "add puzzle":
    discard addPuzzle "whaaat"
    let p = getFreePuzzle()
    check:
      p.initial == "whaaat"
      p.shuffled notin ["whaaat", ""]
      p.logs.len > 1000

  test "stats":
    let st = getStats()
    check:
      st.users == 6
      st.answered == 2
      st.free == 1
      st.total == 5

  test "add attempt":
    discard addAttempt(users{11}, true)
    var at = Attempt(user: User())
    || db.select(at, "user = ? AND succeed", users{11})
    check:
      at.succeed
      at.user.chatid == 11

  test "reset user":
    resetUser getUser(11)

    check getUser(11).state == usInitial
    expect NotFoundError:
      discard getUserPuzzle(users{11})

