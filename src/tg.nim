import std/options
import telebot, telebot/private/types
import markdownv2

type
  TgUserInfo* = tuple
    chatid: int64
    username, firstname, lastname: string

  AdminCommand* = enum
    acCommandslist = "commandslist"
    acStats = "stats"
    acAddpoet = "addpoet"
    acReset = "reset"
    acBackup = "backup"

  TextWithButtons*[S: StyledString or string] = object
    text: S
    keyboard: ReplyKeyboardMarkup

func `!`(so: Option[string]): string =
  if so.isSome: so.get
  else: ""

func extractUserInfo*(c: Chat): TgUserInfo =
  (c.id, !c.username, !c.firstName, !c.lastName)

func toReplyKeyboard*(buttons: seq[string]): ReplyKeyboardMarkup =
  result = newReplyKeyboardMarkup()

  for label in buttons:
    result.keyboard.add @[KeyboardButton(text: label)]

func `++`*[S: string or StyledString] (
    t: S, k: ReplyKeyboardMarkup): TextWithButtons[S] =

  TextWithButtons[S](text: t, keyboard: k)


template `<<.`*(chatid: int64, text: string): untyped {.dirty.} =
  discard await bot.sendMessage(chatid, text)

template `<<`*(chatid: int64, text: string): untyped {.dirty.} =
  asyncCheck bot.sendMessage(chatid, text)

template `<<`*(chatid: int64, text: StyledString): untyped {.dirty.} =
  asyncCheck bot.sendMessage(chatid, text.string, parsemode = "MarkdownV2")

template `<<`*(chatid: int64, box: TextWithButtons): untyped {.dirty.} =
  asyncCheck bot.sendMessage(chatid,
    box.text.string,
    replyMarkup = box.keyboard)
