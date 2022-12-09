# Package

version       = "0.0.1"
author        = "hamidb80"
description   = "Yaldaaa Code telegram bot"
license       = "MIT"
srcDir        = "src"
bin           = @["main"]


# Dependencies

requires "nim >= 1.6.6"
requires "norm >= 2.6.0"
requires "telebot >= 2022.11.07"

task debug, "runs the code": 
  exec "nim -d:ssl --mm:orc r ./src/main.nim"

task gen, "generate final executeable file": 
  exec "nim -d:release -d:ssl --mm:orc c ./src/main.nim"