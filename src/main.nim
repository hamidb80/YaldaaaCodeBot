import std/[asyncdispatch, strutils, os, options, logging]
import telebot, norm/sqlite
import dialogs, database, tg, utils

# --- events

proc userHey(bot: TeleBot, c: Chat): Future[void] {.gcsafe, async.} =
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

proc startCommandHandler(bot: Telebot, c: Command): Future[bool] {.gcsafe, async.} =
  result = true
  await bot.userHey(c.message.chat)

proc problemCommandHandler(bot: Telebot, c: Command): Future[bool] {.gcsafe, async.} =
  result = true
  c.message.chat.id << problemDescWhereD

proc helpCommandHandler(bot: Telebot, c: Command): Future[bool] {.gcsafe, async.} =
  result = true
  discard await bot.sendPhoto(c.message.chat.id, "file://" & getCurrentDir() / "assets/help.png")

proc adminCommandHandler(bot: Telebot, c: Command): Future[bool] {.gcsafe, async.} =
  result = true
  let u = addOrGetUser extractUserInfo c.message.chat

  if u.isAdmin:
    try:
      case c.command
      of $acCommandslist:
        u.chatid << adminCommandsD

      of $acStats:
        u.chatid << reprStats getStats()

      of $acAddpoet:
        if isValidPoet c.params:
          let p = addPuzzle c.params.strip.replace("\n", " ")
          u.chatid << puzzleEmail p
          u.chatid << savedD
        else:
          u.chatid << poetFormatAlertD

      of $acWinners:
        for w in getWinners():
          w.chatid << winnerSendMeD

      of $acReset:
        let uid = parseInt c.params
        resetUser getUser(uid)
        u.chatid << resetedD

      of $acPromote:
        let uid = parseInt c.params

        try:
          var a = getUser(uid)
          a.isAdmin = true
          update a
          u.chatid << promoteMsg a

        except NotFoundError:
          u.chatid << thereIsNoUser

    except ValueError:
      u.chatid << invalidInputD

    except:
      u.chatid << problemAccuredD

  else:
    u.chatid << youAreNotAdminMyDearD

proc onMessage(bot: Telebot, m: Message): Future[bool] {.gcsafe, async.} =
  result = true
  let
    u = addOrGetUser extractUserInfo m.chat
    t = m.text.get("")

  case u.state
  of usInitial:
    asyncCheck bot.userHey(m.chat)

  of usProblem:
    case t
    of wannaAnswerD:
      u.chatid << doubtSolvedProblemD ++ emptyK
      update u, usAnswer

    of sendMyInputsD:
      let p = getUserPuzzle u

      u.chatid << problemNoticeD
      u.chatid << puzzleEmail p
      let path = writeTempFile(".log.txt", p.logs)
      discard await bot.sendDocument(u.chatid, "file://" & path,
          caption = "log.txt")

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
          usWon
        else:
          u.chatid << sorryTryAgainD ++ problemK
          usProblem

    else:
      update u, usProblem
      u.chatid << poetFormatAlertD ++ problemK

  of usWon:
    u.chatid << youWonAlreadyD

proc onUpdate(bot: Telebot, up: Update): Future[bool] {.gcsafe, async.} =
  if issome up.message:
    return await onMessage(bot, up.message.get)
  else:
    return true

# --- go

# TODO send photos and docs with `<@` infix

when isMainModule:
  let
    authorId = parseInt getEnv "AUTHOR_CHAT_ID"
    token = getEnv "TG_BOT_API_KEY"
    bot = newTeleBot token

  # --- log information

  echo "TOKEN: ", token
  var L = newConsoleLogger(fmtStr = "$levelname, [$time]")
  addHandler(L)

  # --- register commands

  bot.onCommand("start", startCommandHandler)
  bot.onCommand("problem", problemCommandHandler)
  bot.onCommand("help", helpCommandHandler)
  for c in AdminCommand:
    bot.onCommand($c, adminCommandHandler)

  # --- prepare db

  createDB()

  if getAdmins().len == 0:
    discard addUser(authorId, "hamidb80", "Hamid", "Bluri", true)

  # --- run bot

  discard waitfor bot.sendMessage(authorId, "started ⚒")
  bot.onUpdate onUpdate
  bot.poll 300
