import std/[asyncDispatch, strutils, os, options, logging]
import telebot, norm/sqlite
import dialogs, database, tg


var L = newConsoleLogger(fmtStr = "$levelname, [$time] ")
addHandler(L)

# --- events

proc begin(bot: TeleBot, c: Chat): Future[void] {.async, gcsafe.} =
  let u = addOrGetUser extractUserInfo c

  case u.state
  of usInitial:
    u.chatid << greetingD ++ problemK

    try:
      var p = getFreePuzzle()
      p.belongs = some u
      update u, usProblem
      update p
  
    except NotFoundError:
      u.chatid << wereOutOfPuzzles

      for a in getAdmins():
        a.chatid << outputPuzzleAlertD

  else:
    u.chatid << youAttendedBeforeD ++ problemK

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
      let uid = parseInt c.params
      resetUser getUser(uid)
      u.chatid << resetedD

    of $acPromote:
      let uid = parseInt c.params
      var u = getUser(uid)

      u.isAdmin = true
      update u

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
    authorId = parseInt getEnv "AUTHOR_CHAT_ID"
    token = getEnv "TG_BOT_API_KEY"
    bot = newTeleBot token

  echo "TOKEN: ", token

  bot.onCommand("start", startCommandHandler)
  for c in AdminCommand:
    bot.onCommand($c, adminCommandHandler)

  if not fileExists getEnv "DB_HOST":
    createDB()
    # TODO add admin [author ID]
    authorId << "start ..."

  bot.onUpdate onUpdate
  bot.poll 300
