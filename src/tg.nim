import std/options
import telebot

type
  TgUserInfo* = tuple
    chatid: int64
    username, firstname, lastname: string

func `!`(so: Option[string]): string =
  if so.isSome: so.get
  else: ""

func extractUserInfo*(msg: Message): TgUserInfo =
  let c = msg.chat
  (c.id, !c.username, !c.firstName, !c.lastName)
