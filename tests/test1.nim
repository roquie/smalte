import os
import unittest
import smaltepkg/engine as smalte

suite "Replace environment varibles":

  test "it should be work with real config file, like nginx":
    os.putEnv("NGINX_WORKER_PROCS", "auto")
    os.putEnv("NGINX_SENDFILE", "off")
    os.putEnv("NGINX_PORT", "8080")
    os.putEnv("NGINX_WEBROOT", "/srv/www")
    smalte.build(@["./tests/stubs/test_nginx.conf.tmpl:/tmp/smalte_nginx.conf"], @["NGINX\\.*"])
    check(readFile("./tests/stubs/true_nginx.conf") == readFile("/tmp/smalte_nginx.conf"))

  test "it should be work with multiple scopes":
    os.putEnv("SCOPE1_VAR1", "FOO")
    os.putEnv("SCOPE1_VAR2", "BAR")
    os.putEnv("SCOPE2_VAR1", "FOO")
    os.putEnv("SCOPE2_VAR2", "BAR")
    smalte.build(@["./tests/stubs/multiple_scopes.txt.tmpl:/tmp/multiple_scopes.txt"], @["SCOPE1\\.*", "SCOPE2"])
    check(readFile("./tests/stubs/true_multiple_scopes.txt") == readFile("/tmp/multiple_scopes.txt"))

  test "it should be work with figure brackets and in global scope":
    os.putEnv("FIGURE_BRACKETS1", "expecto ")
    os.putEnv("FIGURE_BRACKETS2", "patronum")
    smalte.build(@["./tests/stubs/figure_brackets.txt.tmpl:/tmp/figure_brackets.txt"], @[], true)
    check(readFile("./tests/stubs/true_figure_brackets.txt") == readFile("/tmp/figure_brackets.txt"))
