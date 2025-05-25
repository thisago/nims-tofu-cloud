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
