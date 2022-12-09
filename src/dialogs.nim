import std/[strutils, strformat]
import database, markdownv2, tg

const
  greetingD* = ss """
    سلام به مسابقه *یلدا کد* انجمن علمی مهندسی کامپیوتر دانشگاه شاهد خوش اومدی!
  """

  youAreNotAdminMyDearD* = """
    عزیزم شما ادمین نیستی
  """

  sendMyInputsD* = """
    ورودی هامو بفرست
  """

  wannaAnswerD* = """
    میخوام جواب رو بدم
  """

  doubtSolvedProblemD* = """ 
    واقعا فکر میکنی جواب درست رو پیدا کردی؟ 
  """
  sendToProveD* = """ 
    خب اگر راست میگی جوابو بفرست ببینم ...
  """

  congratsD* = """
    ایول بابا! خود خودشه!
  """

  weWillInformYouD* = """
    حتما نتیجه قرعه کشی رو اعلام میکنیم
  """

  youWonAlreadyD* = """
    مسابقه همین یدونه سوال بود که جواب دادی! یلدا خوش بگذره!
  """

  poetFormatAlertD* = """
    الگوی شعر اشتباه است. توجه کنید که باید بین دو مصرع ` *** ` بیاید.
  """

  savedD* = """
    ثبت شد
  """

  youAttendedBeforeD* = """
    شما قبلا در مسابقه شرکت کرده اید
  """

  resetedD* = """
    ریست شد
  """

  invalidInputD* = """
    ورودی نامعتبر
  """



  adminCommandsD* = fmt"""
    /{$acStats}: آمار
    /{$acAddpoet}: اضافه کردن شعر
    /{$acReset}: ریست کردن با کاربر با ورودی chatid
    /{$acBackup}: بکاپ گرفتن از دیتابیس

    مثال استفاده:
    /{$acStats}
    /{$acAddpoet} ملکا ذکر تو گویم *** که تو پاکی و خدایی
    /{$acReset} 101862091
    /{$acBackup} 
  """

let
  problemK* = toReplyKeyboard @[sendMyInputsD, wannaAnswerD]

func reprStats*(st: Stats): string =
  fmt"""
    شرکت کننده ها: {st.users}
    حل کرده: {st.answered}
    شعر های آزاد: {st.free}
    همه شعر ها: {st.total}
  """

func isValidPoet*(sentence: string): bool =
  " *** " in sentence
