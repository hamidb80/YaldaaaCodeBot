import std/[options, os, strutils]
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
    acPromote = "promote"
    acWinners = "winners"

  TextWithButtons*[S: StyledString or string] = object
    text: S
    keyboard: KeyboardMarkup

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
    t: S, k: KeyboardMarkup): TextWithButtons[S] =

  TextWithButtons[S](text: t, keyboard: k)


# XXX nim has some problems with asyncCheck in except branch, so I use discard await instead

const md2 = "MarkdownV2"

type FileType = enum
  ftDocument
  ftPicture

func fileType(path: string): FileType =
  case path.splitFile.ext.toLowerAscii
  of ".png", ".jpg": ftPicture
  else: ftDocument

proc staticFileAddr*(path: string): string =
  "file://" & getCurrentDir() / path

template `<@`*(chatid: int64, data: tuple[path, text: string]): untyped =
  case fileType(data[0])
  of ftDocument:
    discard await bot.sendDocument(chatid, data[0], caption = data[1])
  of ftPicture:
    discard await bot.sendPhoto(chatid, data[0], caption = data[1])

template `<<`*(chatid: int64, text: string): untyped =
  discard await bot.sendMessage(chatid, text)

template `<<`*(chatid: int64, text: StyledString): untyped =
  discard await bot.sendMessage(chatid, text.string, parsemode = md2)

template `<<`*[S: string or StyledString](chatid: int64,
    box: TextWithButtons[S]): untyped =

  const pmode =
    when S is StyledString: md2
    else: ""

  discard await bot.sendMessage(chatid,
    box.text.string,
    parsemode = pmode,
    replyMarkup = box.keyboard)
