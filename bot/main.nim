import std/[asyncDispatch, strutils, os, options]
import telebot, norm/[sqlite, model]
import dialogs, aliases, database


# --- type defs

type
  AdminCommand = enum
    stats, addpoet, reset, backup

# --- events

proc startCommandHandler(bot: Telebot, c: Command): Future[bool] {.async.} =
  result = true
  c.message.chat.id << greetingD

proc onMsg(bot: Telebot, up: Update): Future[bool] {.async.} =
  if issome up.message:
    discard

  result = true

proc adminCommandHandler(bot: Telebot, cmd: Command): Future[bool] {.async.} =
  result = true

  case cmd.command
  of $stats: discard
  of $addpoet: discard
  of $reset: discard
  of $backup: discard

# --- go

when isMainModule:
  let bot = newTeleBot(getEnv("TG_BOT_API_KEY"))

  bot.onCommand("start", startCommandHandler)
  for c in AdminCommand:
    bot.onCommand($c, adminCommandHandler)

  bot.onUpdate(onMsg)
  bot.poll(timeout = 300)
