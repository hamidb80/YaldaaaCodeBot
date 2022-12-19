import std/[strformat]
import database

var result = """
<style>
*{
  padding: 0;
  margin: 0;
  direction: rtl;
  font-family: "Vazir";
}

li{
  padding: 8px;
}

@import url('https://v1.fontapi.ir/css/Vazir');
</style>
<ol>
"""
for p in allPuzzles():
  result.add fmt"<li> #{p.id} {p.initial} </li>"

writeFile "play.html", result & "</ol>"