import std/[times, strutils, options]
import norm/[model, sqlite, pragmas]
import problem, tg

# --- types

type
  Stats* = tuple
    users, answered, free, total: int64

# --- models

type
  UserState* = enum
    usInitial
    usProblem
    usAnswer
    usWon

  User* = ref object of Model
    chatid*{.unique.}: int64
    username*: string
    firstname*: string
    lastname*: string
    isAdmin*: bool
    state*: UserState

  Puzzle* = ref object of Model
    initial*: string
    logs*: string
    shuffled*: string
    belongs*: Option[User]

  Attempt* = ref object of Model
    user*: User
    timestamp*: Datetime
    succeed*: bool

# --- support for enum field

func dbType*(T: typedesc[enum]): string = "INTEGER"
func dbValue*(val: enum): DbValue = dbValue val.int
func to*(dbVal: DbValue, T: typedesc[enum]): T = dbVal.i.T

# --- utils

proc genPuzzle*(poet: string): Puzzle =
  let (final, logs) = generateProblem(poet, 80 .. 100)
  Puzzle(initial: poet, logs: reprLogs logs, shuffled: final)

# --- aliases

template `||`(code): untyped =
  withDb code

proc update*(u: User, newState: UserState) =
  var tmp = u
  tmp.state = newState
  || db.update tmp

proc update*[M: Model](ins: M) =
  var tmp = ins
  || db.update tmp

proc remove*[M: Model](instance: M) =
  var tmp = instance
  || db.delete tmp

# --- actions

proc getUser*(chatid: int64): User =
  result = User()
  || db.select(result, "chatid == ?", chatid)

proc getAdmins*: seq[User] =
  result = @[User()]
  || db.select(result, "isAdmin")

proc addUser*(tid: int64, u, f, l: string): User =
  result = User(
    chatid: tid,
    username: u,
    firstname: f,
    lastname: l,
    isAdmin: false,
    state: usInitial)

  || db.insert result

proc addOrGetUser*(chatid: int64, u, f, l: string): User =
  try:
    getUser(chatid)
  except NotFoundError:
    addUser(chatid, u, f, l)

proc addOrGetUser*(tu: TgUserInfo): User =
  addOrGetUser(tu.chatid,
    tu.username, tu.firstname, tu.lastname)

proc addPuzzle*(poet: string): Puzzle =
  result = genPuzzle poet
  || db.insert result

proc getFreePuzzle*: Puzzle =
  new result
  || db.select(result, "belongs IS NULL")

proc getUserPuzzle*(u: User): Puzzle =
  result = Puzzle(belongs: some User())
  || db.select(result, "belongs == ?", u)

proc addAttempt*(u: User, c: bool): Attempt =
  result = Attempt(user: u, succeed: c, timestamp: now())
  || db.insert result

proc getStats*: Stats =
  withDb:
    result.users = db.count(User)
    result.answered = db.count(User, "*", false, "state == ?", usWon.int)
    result.free = db.count(Puzzle, "*", false, "belongs IS NULL")
    result.total = db.count(Puzzle)

proc resetUser*(u: sink User) =
  withDb:
    db.transaction:
      u.state = usInitial
      db.update u

      try:
        var p = getUserPuzzle(u)
        reset p.belongs
        db.update p

      except NotFoundError: discard
      except: rollback()

# --- general

proc createDB* =
  || db.createTables Attempt(user: User())
  || db.createTables Puzzle()
