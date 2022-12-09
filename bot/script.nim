when false:
  @user:
    /start
    -> greeting

    block loop:
      case [senMyInputsD, wannaAnswerD]
      of 1:
        -> user.puzzle.shuffled
        -> user.puzzle.logs

      of 2:
        -> doubtSolvedProblemD
        -> sendToProveD

        if msg.removeSpaces == puzzle.initial.removeSpaces:
          -> congratsD
          -> weWillInformYouD

          break loop

        else:
          -> "no dear, that's not the answer"
          continue loop
