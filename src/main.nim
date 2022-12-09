import std/[asyncDispatch, strutils, os, options, strformat]
import telebot
import dialogs, database, tg

# --- events

proc begin(bot: TeleBot, c: Chat): Future[void] {.async, gcsafe.} =
  let u = addOrGetUser extractUserInfo c

  case u.state
  of usInitial:
    u.tgid << greetingD ++ problemK
  else:
    u.tgid << youAttendedBeforeD

  u.state = usProblem
  update u

proc startCommandHandler(bot: Telebot, c: Command): Future[bool] {.async, gcsafe.} =
  result = true
  asyncCheck bot.begin(c.message.chat)

proc adminCommandHandler(bot: Telebot, c: Command): Future[bool] {.async, gcsafe.} =
  result = true
  let u = addOrGetUser extractUserInfo c.message.chat

  if u.isAdmin:
    case c.command
    of $acCommandslist:
      u.tgid << adminCommandsD

    of $acStats:
      u.tgid << reprStats getStats()

    of $acAddpoet:
      if isValidPoet c.params:
        discard addPuzzle c.params.strip
        u.tgid << savedD
      else:
        u.tgid << poetFormatAlertD

    of $acReset:
      resetUser getUser(parseInt c.params)
      u.tgid << resetedD

    of $acBackup:
      u.tgid << "not implemented"

  else:
    u.tgid << youAreNotAdminMyDearD

proc onMessage(bot: Telebot, m: Message): Future[bool] {.async, gcsafe.} =
  let
    u = addOrGetUser extractUserInfo m.chat
    t = m.text.get("")

  case u.state
  of usInitial:
    asyncCheck bot.begin(m.chat)

  of usProblem:
    case t
    of wannaAnswerD:
      discard

    of sendMyInputsD:
      discard

    else:
      u.tgid << invalidInputD

  of usAnswer:
    if isValidPoet t:
      discard
    else:
      u.tgid << poetFormatAlertD

  of usWon:
    u.tgid << youWonAlreadyD


proc onUpdate(bot: Telebot, up: Update): Future[bool] {.async, gcsafe.} =
  if issome up.message:
    return await onMessage(bot, up.message.get)
  else:
    return true

# --- go

when isMainModule:
  let bot = newTeleBot getEnv "TG_BOT_API_KEY"
  asyncCheck bot.setMyCommands @[
    BotCommand(
      command: $acCommandslist,
      description: "لیست دستورات ادمین")]

  bot.onCommand("start", startCommandHandler)
  for c in AdminCommand:
    bot.onCommand($c, adminCommandHandler)

  bot.onUpdate onUpdate
  bot.poll 300
