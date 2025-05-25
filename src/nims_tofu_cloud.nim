from std/json import `%*`, `$`
from std/os import getEnv, fileExists
from std/logging import Level, addHandler, newConsoleLogger, verboseFmtStr

import pkg/jester
from pkg/dotenv import nil

# Load envs if .env file exists
if fileExists ".env":
  dotenv.load(".", ".env")

# Initialize the logger
addHandler(newConsoleLogger(fmtStr = verboseFmtStr))

# Define the routes
routes:
  get "/":
    # TODO: Avoid calling getEnv on every request
    let secret = getEnv "SECRET"
    if request.params.getOrDefault("secret", "") == secret:
      logging.log(Level.lvlInfo, "Valid secret")
      resp %*{
        "message": "Hello, World!",
      }
    else:
      logging.log(Level.lvlWarn, "Invalid secret")
      Http401.resp $(%*{
        "error": "Unauthorized",
      })
