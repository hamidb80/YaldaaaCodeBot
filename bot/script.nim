
when false:
  
  Database:
    User:
      id 
      username
      firstname
      lastname
      contact_info

    Puzzles:
      id
      initial
      log
      final
      
      assigned_to

    Answers:
      user_id
      puzzle_id
      input
      time
      is_correct


  /start
  -> "hello, do you wanna attend 'Ya1daaa C0de'?"

  case [yes, no]
  of yes:
    -> "Happy to see you here then!"

    block loop:
      case ["send inputs", "wanna answer"]
      of 1:
        -> "text"
        -> logs
      of 2:
        -> "Oh, really?, do you think you did solve it?"
        -> "then send your answer to prove ..."

        if out.removeSpaces == user.record.answer:
          -> "Wow! you really did find the answer!"
          -> "would you send your contact to attend to the lottery?"

          if msg == contact:
            save user.contacts
            set user.win = true
            -> "thanks! we will call you if you did win the lottery!"
            break loop
          else:
            -> "please send a contant"

        else:
          -> "no dear, that's not the answer"
          continue loop

  of no:
    -> "so sad, maybe next year ..."
