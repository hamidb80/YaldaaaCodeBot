import std/[unittest, os]
import database, problem

# --- sample data

let 
  users = [

  ] 

  puzzles = [

  ]

  attempts = [

  ]



# --- 

suite "DataBase":

  putEnv("DB_HOST", "./test.db")
  createDB()


  # test ""

  # withDb:
  #   for (uname, tgid) in [("ali", 12), ("hamid", 13), ("majid", 14)]:
  #     var u = User(state: initial, username: uname, tgid: tgid)
  #     db.insert(u)

  echo getUser(13)[]
  # for u in users:
  #   echo u[]

