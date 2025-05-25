from std/json import `%*`, `$`
from std/os import getEnv

import pkg/jester
from dotenv import nil

dotenv.load(".", ".env")

let secret = getEnv "SECRET"

routes:
  get "/":
    if request.params.getOrDefault("secret", "") == secret:
      resp %*{
        "message": "Hello, World!",
      }
    else:
      Http401.resp $(%*{
        "error": "Unauthorized",
      })
