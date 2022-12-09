import std/[times, strutils, options]
import norm/[model, sqlite, pragmas]
import problem, tg


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
    tgid* {.unique.}: int64
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
    succeed*: bool

# --- support for enum field

func dbType*(T: typedesc[enum]): string = "INTEGER"
func dbValue*(val: enum): DbValue = dbValue val.int
func to*(dbVal: DbValue, T: typedesc[enum]): T = dbVal.i.T

# --- aliases

template `||`(code): untyped =
  withDb code

proc update*(u: sink User, newState: UserState) =
  u.state = newState
  || db.update u

proc update*[M: Model](ins: sink M) =
  || db.update ins

proc remove*[M: Model](instance: sink M) =
  var tmp = instance
  || db.delete tmp

# --- actions

proc getUser*(tgid: int64): User =
  result = User()
  || db.select(result, "tgid == ?", tgid)

proc addUser*(tid: int64, u, f, l: string): User =
  result = User(
    tgid: tid,
    username: u,
    firstname: f,
    lastname: l,
    is_admin: false,
    state: usInitial)

  || db.insert result

proc addOrGetUser*(tgid: int64, u, f, l: string): User =
  try:
    getUser(tgid)
  except NotFoundError:
    addUser(tgid, u, f, l)

proc addOrGetUser*(tu: TgUserInfo): User =
  addOrGetUser(tu.chatid,
    tu.username, tu.firstname, tu.lastname)

proc addPuzzle*(poet: string): Puzzle =
  let (final, logs) = generateProblem(poet, 80 .. 100)
  result = Puzzle(initial: poet, logs: reprLogs logs, shuffled: final)
  || db.insert result

proc getNewPuzzle*: Puzzle =
  || db.select(result, "assigned_to == NULL")

proc getUserPuzzle*(u: User): Puzzle =
  || db.select(result, "assigned_to == ?", u)

proc addAttempt*(u: User, c: bool): Attempt =
  result = Attempt(user: u, succeed: c, timestamp: now())
  || db.insert result

proc getStats*: Stats =
  withDb:
    result.users = db.count(User)
    result.answered = db.count(User, "*", false, "state == ?", usWon.int)
    result.free = db.count(Puzzle, "*", false, "assigned_to == NULL")
    result.total = db.count(Puzzle)

proc resetUser*(u: sink User) =
  withDb:
    db.transaction:
      u.state = usInitial
      db.update u

      try:
        var p = getUserPuzzle(u)
        reset p.assigned_to
        db.update p

      except NotFoundError: discard
      except: rollback()

# --- general

proc createDB* =
  || db.createTables User()
  || db.createTables Puzzle()
  || db.createTables Attempt(user: User())
