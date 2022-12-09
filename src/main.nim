import std/[asyncDispatch, strutils, os, options]
import telebot
import dialogs, aliases, database


# --- type defs

type
  AdminCommand = enum
    stats, addpoet, reset, backup

# --- events

proc startCommandHandler(bot: Telebot, c: Command): Future[bool] {.async.} =
  result = true
  c.message.chat.id << greetingD

  

proc adminCommandHandler(bot: Telebot, c: Command): Future[bool] {.async.} =
  result = true

  case c.command
  of $stats: discard
  of $addpoet: discard
  of $reset: discard
  of $backup: discard

proc onMessage(bot: Telebot, m: Message): Future[bool] {.async.} =
  discard
  # sendMessage( replyMarkup = )

proc onUpdate(bot: Telebot, up: Update): Future[bool] {.async.} =
  if issome up.message:
    return await onMessage(bot, up.message.get)
  else:
    return true

# --- go

when isMainModule:
  let bot = newTeleBot getEnv "TG_BOT_API_KEY"

  bot.onCommand("start", startCommandHandler)
  for c in AdminCommand:
    bot.onCommand($c, adminCommandHandler)

  bot.onUpdate onUpdate
  bot.poll 300
