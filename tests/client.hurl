# Test for Unauthorized Request

GET {{HOST}}/?secret=invalid_secret
HTTP 401
[Asserts]
jsonpath  "$.error" == "Unauthorized"

# Test for Authorized Request

GET {{HOST}}/?secret={{SECRET}}
HTTP 200
[Asserts]
jsonpath  "$.message" == "Hello, World!"
