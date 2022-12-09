import std/[unittest, os]
import database

# --- sample data

# let
#   users = [

#   ]

#   puzzles = [

#   ]

#   attempts = [

#   ]



# --- tests

suite "DataBase":
  putEnv("DB_HOST", ":memory:")
  createDB()

  # test ""

  # withDb:
  #   for (uname, tgid) in [("ali", 12), ("hamid", 13), ("majid", 14)]:
  #     var u = User(state: initial, username: uname, tgid: tgid)
  #     db.insert(u)

  # echo getUser(13)[]
  # for u in users:
  #   echo u[]

