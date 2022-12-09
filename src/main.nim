import std/[asyncDispatch, strutils, os, options]
import telebot
import dialogs, database, tg

# --- events

proc begin(bot: TeleBot, c: Chat): Future[void] {.async, gcsafe.} =
  let u = addOrGetUser extractUserInfo c

  case u.state
  of usInitial:
    u.tgid << greetingD ++ problemK

    var p = getNewPuzzle()
    p.assigned_to = some u
    update u, usProblem
    update p

  else:
    u.tgid << youAttendedBeforeD

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
      # TODO error handling for parsing invlid int
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
      u.tgid << doubtSolvedProblemD
      update u, usAnswer

    of sendMyInputsD:
      u.tgid << reprInputs getUserPuzzle u

    else:
      u.tgid << invalidInputD

  of usAnswer:
    if isValidPoet t:
      let
        p = getUserPuzzle(u)
        isCorrect = p.initial.cleanPoet == t.cleanPoet

      discard addAttempt(u, isCorrect)

      update u:
        if isCorrect:
          u.tgid << congratsD
          u.tgid << youWonAlreadyD
          usWon
        else:
          u.tgid << sorryTryAgainD
          usProblem

    else:
      update u, usProblem
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
