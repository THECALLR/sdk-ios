sdk-ios
=======

SDK in Swift for THECALLR API

## Basic Example (Send SMS)
See App example in [ThecallrApiDemo](ThecallrApiDemo/)

```swift
// Set your credentials
var api = ThecallrApi(login: "login", password: "password")

api.call("sms.send", params: "THECALLR", "+33123456789", "hello world!", ["flash_message": false])
.success({ (result) -> Void in
  println(result)
})
.failure({ (error) -> Void in
	println(error)
})
```
