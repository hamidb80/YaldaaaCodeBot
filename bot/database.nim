import std/[times, strutils, os, options]
import norm/[model, sqlite]
import ndb/sqlite as ns



type
  UserState = enum
    initial
    problem
    answer
    won

  User* = ref object of Model
    tgid*: int
    username*: string
    firstname*: string
    lastname*: string
    is_admin*: bool
    state*: UserState

  Puzzle* = ref object of Model
    initial*: string
    log*: string
    shuffled*: string
    assigned_to*: Option[User]

  Answer* = ref object of Model
    user*: User
    input*: string
    timestamp*: Datetime
    is_correct*: bool


func dbType*(T: typedesc[enum]): string = "INTEGER"
func dbValue*(val: enum): DbValue = dbValue val.int
func to*(dbVal: DbValue, T: typedesc[enum]): T = dbVal.i.T


when isMainModule:
  withDb:
    db.createTables(Answer(user: User()))
    db.createTables(Puzzle())

  var u1 = User(state: initial)
  withDb:
    db.insert(u1)
