import os, osproc, webgui, strutils, streams, times

type
  Compile = enum
    Debug
    Release

let app = newWebView(currentHtmlPath(), title = "Compile nim", height = 666) #, width = 666)


proc nCcompile(c: string) =
  #var p = startProcess("/usr/bin/nim", args=["c", "-r", "test.nim"], options = {poStdErrToStdOut})
  var p = startProcess("/usr/bin/nim " & c, options = {poStdErrToStdOut, poEvalCommand})
  var outp = outputStream(p)
  close inputStream(p)

  app.js(app.addText("#output", "👑______________________________________________________________👑\n\n" & $now() & "\n\n"))
  
  var line = newStringOfCap(120).TaintedString
  while true:
    if outp.readLine(line):
      app.js("document.querySelector('#output').scrollTop = document.querySelector('#output').scrollHeight;" &
              app.addText("#output", line & "\n\n"))
    else:
      if peekExitCode(p) != -1: break
  close(p)

  app.js(app.addText("#output", "👑______________________________________________________________👑\n"))
  app.js("document.querySelector('#output').scrollTop = document.querySelector('#output').scrollHeight;")


proc genCommand(c: Compile, s: string) =
  ## Generate the command line
  
  if c == Debug:
    nCcompile("c -d:dev -r " & s)
  elif c == Release:
    nCcompile("c -d:release -r " & s)
  

app.bindProcs("api"):
  proc jsnCrelease(s: string) = genCommand(Release, s)
  proc jsnCdev(s: string)     = genCommand(Debug, s)


let dirName = lastPathPart(getCurrentDir())
const fileHtml = """<input id="filename" value="$1" style="width: 100%; text-align: center;">"""
app.js(app.addHtml("#file", fileHtml.format(dirName & ".nim"), position=afterbegin))

app.run()
app.exit()