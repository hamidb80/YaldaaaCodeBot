import telebot

when false:
  /start
  -> greeting

  case [yes, no]
  of yes:
    -> welcome

    block loop:
      case [senMyInputs, wannaAnswer]
      of 1:
        -> user.puzzle.shuffled
        -> user.puzzle.logs

      of 2:
        -> doubtSolvedProblemD
        -> sendToProveD

        if msg.removeSpaces == user.puzzle.initial.removeSpaces:
          -> congratsD
          -> weWillInformYou
          break loop

        else:
          -> "no dear, that's not the answer"
          continue loop

  of no:
    -> "so sad, maybe next year ..."
