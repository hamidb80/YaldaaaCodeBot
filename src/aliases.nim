template `<<`*(chatid: int64, text: string): untyped {.dirty.} =
  discard await bot.sendMessage(chatid, text, parsemode = "MarkdownV2")
