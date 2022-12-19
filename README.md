# Yaldaaa Code Bot

## Introduction
`Yaldaaa Code` is a programming challenge that is held in the [Yaldā](https://en.wikipedia.org/wiki/Yald%C4%81_Night) times by Computer Engineering Science Club of Shahed University.

## Project Structure

- `src/`
  - `database.nim`: database models and queries
  - `dialogs.nim`: message texts and dialogs
  - `main.nim`: app entry
  - `problem.nim`: problem generator
  - `tg.nim`: extra telegram utilities
  - `markdownv2.nim`: telegram's markdownv2 functionalities
  - `utils.nim`: extra utilities
  - `peoms_list.nim`: lists poems in database to `play.html`
  - `poem_getter.nim`: downloads poems from [Ganjoor API](https://api.ganjoor.net/index.html) and save it in database
- `tests/`
  - `tdb.nim`: test for database
  - `tproblem.nim`: test for problem generator
- `Dockerfile`: docker container config
- `fandogh.sample.yml`: config file for [Fandogh](https://www.fandogh.cloud/) Service
- `yaldaaacode.nimble`: *nimble* project file


## Commands
see `yaldaaacode.nimble`.

### tests 
```
nimble test
```

### build binary
```
nimble gen
```

### debug [local test]
```
nimble debug
```
