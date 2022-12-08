import std/times
import norm/model


type
  User* = ref object of Model
    tgid*: int
    username*: string
    firstname*: string
    lastname*: string

  Puzzle* = ref object of Model
    initial*: string
    log*: string
    shuffled*: string
    assigned_to*: User

  Answers* = ref object of Model
    user*: User
    puzzle*: Puzzle
    input*: string
    timestamp*: Datetime
    is_correct*: bool
