from std/json import `%*`, `$`
from std/os import getEnv, fileExists

import pkg/jester
from pkg/dotenv import nil

# Load envs if .env file exists
if fileExists ".env":
  dotenv.load(".", ".env")

# Define the routes
routes:
  get "/":
    # TODO: Avoid calling getEnv on every request
    let secret = getEnv "SECRET"
    if request.params.getOrDefault("secret", "") == secret:
      resp %*{
        "message": "Hello, World!",
      }
    else:
      Http401.resp $(%*{
        "error": "Unauthorized",
      })
