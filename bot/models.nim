import std/[times, strutils, os, options]
import norm/[model, sqlite]
import ndb/sqlite as ns



type
  State = enum
    initial
    problem
    answer
    won


  User* = ref object of Model
    tgid*: int
    username*: string
    firstname*: string
    lastname*: string
    state*: State

  Puzzle* = ref object of Model
    initial*: string
    log*: string
    shuffled*: string
    assigned_to*: Option[User]

  Answer* = ref object of Model
    user*: User
    puzzle*: Puzzle
    input*: string
    timestamp*: Datetime
    is_correct*: bool


func dbType*(T: typedesc[enum]): string = "INTEGER"
func dbValue*(val: enum): DbValue = dbValue val.int
func to*(dbVal: DbValue, T: typedesc[enum]): T = dbVal.i.T


putEnv("DB_HOST", "./test.db")
let db = getDb()

# TODO pooling

var u1 = User(state: initial)
db.createTables(Answer(user: User(), puzzle: Puzzle()))
db.insert(u1)
