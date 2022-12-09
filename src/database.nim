import std/[times, strutils, os, options]
import norm/[model, sqlite, pragmas]
import problem

# --- models

type
  UserState = enum
    usInitial
    usProblem
    usAnswer
    usWon

  User* = ref object of Model
    tgid* {.unique.}: int
    username*: string
    firstname*: string
    lastname*: string
    is_admin*: bool
    state*: UserState

  Puzzle* = ref object of Model
    initial*: string
    logs*: string
    shuffled*: string
    assigned_to*: Option[User]

  Attempt* = ref object of Model
    user*: User
    timestamp*: Datetime
    is_correct*: bool

# --- support for enum field

func dbType*(T: typedesc[enum]): string = "INTEGER"
func dbValue*(val: enum): DbValue = dbValue val.int
func to*(dbVal: DbValue, T: typedesc[enum]): T = dbVal.i.T

# --- aliases

template `||`(code): untyped =
  withDb code

proc update*[M: Model](u: M) =
  || db.update u

proc remove*[M: Model](instance: sink M) =
  var tmp = instance
  || db.delete tmp

# --- actions

proc addUser*(tgid: int): User =
  # TODO
  discard

proc getUser*(tgid: int): User =
  result = User()
  || db.select(result, "tgid == ?", tgid)

proc addOrGetUser*(tgid: int, username, firstname, lastname: string): User =
  # TODO
  discard

proc addPuzzle*(poet: string): Puzzle =
  let (final, logs) = generateProblem(poet, 300 .. 500)
  result = Puzzle(initial: poet, logs: reprLogs logs, shuffled: final)
  || db.insert result

proc getNewPuzzle*: Puzzle =
  || db.select(result, "assigned_to == NULL")

proc getUserPuzzle*(u: User): Puzzle =
  || db.select(result, "assigned_to == ?", u)

proc setAttempt*(u: User, c: bool): Attempt =
  result = Attempt(user: u, is_correct: c, timestamp: now())
  || db.insert result

proc getPuzzlesStats*: tuple[answered, free, total: int64] =
  withDb:
    result.answered = db.count(User, "1", false, "state == ?", usWon.int)
    result.free = db.count(Puzzle, "1", false, "assigned_to == NULL")
    result.total = db.count(Puzzle)

# -- test

when isMainModule:
  # TODO put your test data in .csv files and then test actions
  
  putEnv("DB_HOST", "./test.db")

  || db.createTables User()
  || db.createTables Puzzle()
  || db.createTables Attempt(user: User())

  # withDb:
  #   for (uname, tgid) in [("ali", 12), ("hamid", 13), ("majid", 14)]:
  #     var u = User(state: initial, username: uname, tgid: tgid)
  #     db.insert(u)

  echo getUser(13)[]
  # for u in users:
  #   echo u[]
