import os
import re
import strutils
import threadpool

type
  AllowedEnvToReplace = tuple[pattern: Regex, repl: string]
  TemplateConfig = tuple[tmpl: string, config: string]

var
  env: seq[AllowedEnvToReplace] = @[]
  files: seq[TemplateConfig] = @[]

{.experimental.}
proc transform(files: seq[TemplateConfig]) =
  parallel:
    for item in files:
      spawn re.transformFile(item.tmpl, item.config, env)

proc build*(fileStrings: seq[string], scopes: seq[string], global: bool = false) =
  for file in fileStrings:
    let capsule = file.split(':')
    files.add((tmpl: capsule[0], config: capsule[1]))

  for key, value in os.envPairs():
    let pattern = ("\\$$(\\{?)$1(\\}?)" % [key]).re
    if global:
      env.add((pattern, value))
    else:
      for scope in scopes:
        if key.find(scope.re) != -1:
          env.add((pattern, value))

  transform(files)
