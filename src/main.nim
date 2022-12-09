import std/[asyncDispatch, strutils, os, options]
import telebot
import dialogs, database, tg

# --- events

proc begin(bot: TeleBot, c: Chat): Future[void] {.async, gcsafe.} =
  let u = addOrGetUser extractUserInfo c

  case u.state
  of usInitial:
    u.chatid << greetingD ++ problemK

    var p = getFreePuzzle()
    p.belongs = some u
    update u, usProblem
    update p

  else:
    u.chatid << youAttendedBeforeD

proc startCommandHandler(bot: Telebot, c: Command): Future[bool] {.async, gcsafe.} =
  result = true
  asyncCheck bot.begin(c.message.chat)

proc adminCommandHandler(bot: Telebot, c: Command): Future[bool] {.async, gcsafe.} =
  result = true
  let u = addOrGetUser extractUserInfo c.message.chat

  if u.isAdmin:
    case c.command
    of $acCommandslist:
      u.chatid << adminCommandsD

    of $acStats:
      u.chatid << reprStats getStats()

    of $acAddpoet:
      if isValidPoet c.params:
        discard addPuzzle c.params.strip
        u.chatid << savedD
      else:
        u.chatid << poetFormatAlertD

    of $acReset:
      # TODO error handling for parsing invlid int
      resetUser getUser(parseInt c.params)
      u.chatid << resetedD

    of $acBackup:
      u.chatid << "not implemented"

  else:
    u.chatid << youAreNotAdminMyDearD

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
      u.chatid << doubtSolvedProblemD
      update u, usAnswer

    of sendMyInputsD:
      u.chatid << reprInputs getUserPuzzle u

    else:
      u.chatid << invalidInputD

  of usAnswer:
    if isValidPoet t:
      let
        p = getUserPuzzle(u)
        isCorrect = p.initial.cleanPoet == t.cleanPoet

      discard addAttempt(u, isCorrect)

      update u:
        if isCorrect:
          u.chatid << congratsD
          u.chatid << youWonAlreadyD
          usWon
        else:
          u.chatid << sorryTryAgainD
          usProblem

    else:
      update u, usProblem
      u.chatid << poetFormatAlertD

  of usWon:
    u.chatid << youWonAlreadyD

proc onUpdate(bot: Telebot, up: Update): Future[bool] {.async, gcsafe.} =
  if issome up.message:
    return await onMessage(bot, up.message.get)
  else:
    return true

# --- go

when isMainModule:
  let 
    bot = newTeleBot getEnv "TG_BOT_API_KEY"
    authorId = parseInt getEnv "AUTHOR_CHAT_ID"

  bot.onCommand("start", startCommandHandler)
  for c in AdminCommand:
    bot.onCommand($c, adminCommandHandler)

  authorId << "start ..."

  bot.onUpdate onUpdate
  bot.poll 300
