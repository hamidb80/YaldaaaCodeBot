import std/[unittest, os, times]
import database

# --- utils

func `{}`(us: seq[User], id: int): User =
  for u in us:
    if u.chatid == id:
      return u

# --- generators

func u(c: int64, u, f, l: string, s: UserState): User =
  User(
    chatid: c,
    username: u,
    firstname: f,
    lastname: l,
    state: s)

proc p(id: int, poet: string): Puzzle =
  result = genPuzzle poet
  result.id = id

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
    p(1, "Hello"),
    p(2, "I Love"),
    p(3, "You tube"),
    p(5, "what"),
    p(6, "are you"),
    p(7, "doing today"),
  ]

  attempts = @[
    a(users{11}, now(), false),
    a(users{11}, now(), false),
    a(users{11}, now(), false),

    a(users{12}, now(), false),

    a(users{13}, now(), false),
    a(users{13}, now(), false),
    a(users{13}, now(), false),
    a(users{13}, now(), false),

    a(users{14}, now(), false),

    a(users{15}, now(), false),
    a(users{15}, now(), false),
  ]

# --- tests

suite "DataBase":
  putEnv("DB_HOST", ":memory:")
  createDB()

  # test ""

  # withDb:
  #   for (uname, chatid) in [("ali", 12), ("hamid", 13), ("majid", 14)]:
  #     var u = User(state: initial, username: uname, chatid: chatid)
  #     db.insert(u)

  # echo getUser(13)[]
  # for u in users:
  #   echo u[]

