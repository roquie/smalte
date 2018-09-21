import strformat
import strutils
import docopt
import smaltepkg/engine

const VERSION = "1.0.0"

let doc = """
> Smalte - is a dead simple and lightweight template engine.

  Example:
    ./smalte build --scope NGINX\.* --scope NPM \
  		test.conf.tmpl:test.conf \
  		test.conf.tmpl:test2.conf \
  		test.conf.tmpl:testN.conf

  Usage:
    smalte build [--scope=<scope> ...] <inputfile:outputfile>...
    smalte (-h | --help)
    smalte (-v | --version)

  Options:
    -h --help      Show this screen.
    -v --version   Show version.
  """

let args = docopt(doc, version = fmt"Smalte v.{VERSION}")
let global = args["build"] and args["--scope"].len == 0

engine.build(@(args["<inputfile:outputfile>"]), @(args["--scope"]), global)
