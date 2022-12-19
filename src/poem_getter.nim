import std/[json, httpclient, os, sequtils, strutils]
import unicode except strip
import database

func removedAva(s: string): string =
  ($s.strip.toRunes.filterIt(it notin "ّةء»«َُِۀًٍـ".toRunes))
  .replace("\U200C", " ")


var client = newHttpClient()

for c in 1..100:
  try:
    echo c
    let verses =
      client
      .getContent("https://api.ganjoor.net/api/ganjoor/poem/random")
      .parseJson["verses"]

    for i in countup(0, verses.len-1, 2):
      let poem = removedAva verses[i]["text"].getStr & " *** " & verses[i+1]["text"].getStr
      discard addPuzzle poem

  except JsonParsingError:
    sleep 100

