import std/[strutils, strformat]
import telebot
import database, markdownv2, tg


const
  greetingD* = ss dedent """
    سلام به مسابقه *یلدا کد* 🍉 انجمن علمی مهندسی کامپیوتر دانشگاه شاهد خوش اومدی\!
    😍

    برای مسابقه آماده ای؟
    👩‍💻
  """

  youAreNotAdminMyDearD* = dedent """
    عزیزم شما ادمین نیستی
    😠
  """

  wereOutOfPuzzles* = dedent """
    متاسفانه ظرفیت پر شده ، من به ادمین خبر میدم...
    
    لطفا نیم ساعت دیگه دوباره امتحان کن
    🕒
  """

  outputPuzzleAlertD* = dedent """
    ظرفیت تموم شده - لطفا شعر اضافه کن
  """

  sendMyInputsD* = strip """
    ورودی هامو بفرست
  """

  wannaAnswerD* = strip """
    میخوام جواب رو بدم
  """

  problemAccuredD* = dedent """
    مشکلی پیش آمد
    🚧
  """

  doubtSolvedProblemD* = dedent """ 
    واقعا فکر میکنی جواب درست رو پیدا کردی؟ 
    خب اگر راست میگی جوابو بفرست ببینم ...
    🤔
  """

  congratsD* = dedent """ 
    ایول بابا! خود خودشه!
    🎉
  """

  sorryTryAgainD* = dedent """ 
    نه درست نیست. دوباره تلاش کن
    🙃
  """

  youWonAlreadyD* = dedent """
    مسابقه همین یدونه سوال بود که جواب دادی! یلدا خوش بگذره!
    😘
  """

  poetFormatAlertD* = dedent """
    نوشتار شعر اشتباه است. توجه کنید که باید بین دو مصرع *** بیاید.
    😓
  """

  problemNoticeD* = ss dedent """
    ⭕ *توجه*
    
    👆 کاراکتر های \" جزو متن ایمیل نمیباشند

    ✌ در فایل log هم هر خط مربوط به یک الگوی بهم ریختگی است
  """

  savedD* = dedent """
    ثبت شد
    ✅
  """

  youAttendedBeforeD* = dedent """
    شما قبلا در مسابقه شرکت کرده اید
    🤨
  """

  resetedD* = dedent """
    ریست شد
    👍
  """

  thereIsNoUser* = dedent """
    کاربر با چنین آیدی در ربات وارد نشده
  """

  invalidInputD* = dedent """
    ورودی نامعتبر
    😦
  """

  adminCommandsD* = dedent fmt"""
    :دستورات
    /{$acStats}: آمار
    /{$acAddpoet}: اضافه کردن شعر
    /{$acReset}: ریست کردن با کاربر ورودی با چت آیدی
    /{$acPromote}: ترفیع به ادمین با چت آیدی

    مثال استفاده:
    /{$acStats}
    /{$acAddpoet} ملکا ذکر تو گویم *** که تو پاکی و خدایی
    /{$acReset} 101862091
    /{$acPromote} 101862091
  """

  emailContentD = strip """
    متن ایمیل
  """

let
  problemK* = toReplyKeyboard @[sendMyInputsD, wannaAnswerD]
  emptyK*: KeyboardMarkup = newReplyKeyboardRemove false


func reprStats*(st: Stats): string =
  dedent fmt"""
    شرکت کننده ها: {st.users}
    حل کرده: {st.answered}
    شعر های آزاد: {st.free}
    همه شعر ها: {st.total}
  """

func promoteMsg*(u: database.User): string =
  const
    userD = "کاربر"
    withNameD = "با نام"
    gotpromotedD = "ترفیع داده شد"

  fmt "{userD} {withNameD} '{u.firstname} {u.lastname}' {gotpromotedD}"

func puzzleEmail*(p: Puzzle): StyledString =
  ss dedent fmt "{bold emailContentD}:\n\"{escapemd2 p.shuffled}\""

func isValidPoet*(sentence: string): bool =
  "***" in sentence

func cleanFrom(s: string, excluded: set[char]): string =
  for ch in s:
    if ch notin excluded:
      result.add ch

func cleanPoet*(s: string): string =
  cleanFrom s, {' ', '*'}
