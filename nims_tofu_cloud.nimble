# Package

version       = "0.1.0"
author        = "thisago"
description   = "Nim Hello World HTTP server deployed on AWS cloud via Open Tofu"
license       = "MIT"
srcDir        = "src"
bin           = @["nims_tofu_cloud"]
binDir = "build"


# Dependencies

requires "nim >= 1.6.10"

requires "jester >= 0.6.0"
requires "dotenv >= 2.0.0"

from std/strformat import fmt

const hurlVariablesFile = ".env"

task test, "Run Hurl tests":
  exec fmt"hurl --variables-file {hurlVariablesFile} ./tests/*.hurl"

task build_release, "Build release version":
  exec "nimble build -d:danger --opt:speed"
