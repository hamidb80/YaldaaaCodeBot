# --- Package

version       = "0.0.1"
author        = "hamidb80"
description   = "Yaldaaa Code telegram bot"
license       = "MIT"
srcDir        = "src"
bin           = @["main"]

# --- Dependencies

requires "nim >= 1.6.6"
requires "norm >= 2.6.0"
requires "telebot >= 2022.11.07"

task debug, "runs on your computer for testing/debuging": 
  putenv "AUTHOR_CHAT_ID", "101862091"
  putenv "DB_HOST", "./test.db"
  exec "nim -d:ssl --mm:orc r ./src/main.nim"

task gen, "generate final executeable file": 
  # exec "nim -f -d:release -d:ssl --out:bin.exe c ./src/main.nim"
  exec "nim -f -d:ssl --out:bin.exe c ./src/main.nim"

# --- reminder

# fandogh image init --name ylcdbt
# fandogh image publish --version ...
# fandogh service apply -f fandogh.yml