import std/tempfiles

proc writeTempFile*(postfix, content: string): string =
  let (f, path) = createTempFile("", postfix)
  f.write(content)
  f.close
  path