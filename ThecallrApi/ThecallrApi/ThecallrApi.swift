//
//  Api.swift
//  ThecallrApi
//
//  Created by THECALLR on 22/09/14.
//  Copyright (c) 2014 THECALLR. All rights reserved.
//

import Foundation

class ThecallrApi {

	private let login, password: String!

	init(login: String, password: String) {
		self.login = login
		self.password = password
	}

	func call(method: String, params: AnyObject...) -> ThecallrApiRequestHandler {
		return self.send(method, params: params, id: 0)
	}

	func send(method: String, params: Array<AnyObject>) -> ThecallrApiRequestHandler {
		return self.send(method, params: params, id: 0)
	}

	func send(method: String, params: Array<AnyObject>, id: Int) -> ThecallrApiRequestHandler {
		// create Dictionary to be converted to json
		let dictionary: [String: AnyObject] = [
			"jsonrpc": "2.0",
			"id": id != 0 ? id : NSInteger(100 + arc4random_uniform(900)),
			"method": method,
			"params": params
		]

		// convert dictionary to json string
		var err: NSError?
		let data: NSData! = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions(0), error: &err)

		// encode login/password to basicAuth format
		let auth: NSData! = "\(self.login):\(self.password)".dataUsingEncoding(NSUTF8StringEncoding)
		let basicAuth: NSString = auth.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromMask(0))

		// create and return new instance for request
		return ThecallrApiRequestHandler(data: data, basicAuth: basicAuth).exec()
	}

}

class ThecallrApiRequestHandler : NSObject {

	private let API = "https://api.thecallr.com"

	private var successCallback: ((AnyObject) -> Void)?
	private var failureCallback: ((AnyObject) -> Void)?

	private let dataOut: NSData!
	private var dataIn: NSMutableData = NSMutableData()

	private let basicAuth: NSString!

	private var statusCode: Int = 0

	init(data: NSData!, basicAuth: NSString!) {
		self.dataOut = data
		self.basicAuth = basicAuth
	}

	// prepare and send request
	internal func exec(Void) -> ThecallrApiRequestHandler {
		let req = NSMutableURLRequest(URL: NSURL(string: self.API))

		req.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
		req.setValue("application/json-rpc; charset=utf-8", forHTTPHeaderField: "Content-Type")
		req.setValue(String(dataOut.length), forHTTPHeaderField: "Content-Length")
		req.HTTPMethod = "POST"
		req.HTTPBody = dataOut

		NSURLConnection(request: req, delegate: self, startImmediately: true)
		return self
	}

	// Request response headers
	private func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSHTTPURLResponse!) {
		statusCode = response.statusCode
	}

	// Request response data
	private func connection(connection: NSURLConnection!, didReceiveData conData: NSData!) {
		dataIn.appendData(conData)
	}

	// Request failed
	private func connection(connection: NSURLConnection!, didFailWithError: NSError!) {
		if (failureCallback != nil) {
			let error: [String:AnyObject] = [
				"code": didFailWithError.code,
				"message": "HTTP_EXCEPTION",
				"NSError": didFailWithError
			]
			failureCallback!(error)
		}
	}

	// Request ended
	// Begin data processing
	private func connectionDidFinishLoading(connection: NSURLConnection!) -> Void {
		// Check response code
		if statusCode != 200 && failureCallback != nil {
			let error: [String:AnyObject] = [
				"code": statusCode,
				"message": "HTTP_CODE_ERROR"
			]
			return failureCallback!(error)
		}

		// Convert (json) string to dictionary
		// It will fail if string is not json and "err" will be != nil
		var error: NSError?
		let json: NSDictionary? = NSJSONSerialization.JSONObjectWithData(dataIn, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary

		// check for error
		if error == nil && json != nil && json!["result"] != nil {
			if successCallback != nil {
				return successCallback!(json!["result"]!)
			}
			return ;
		}
		else if failureCallback != nil && error == nil && json != nil && json!["error"] != nil {
			return failureCallback!(json!["error"]!)
		}
		else {
			if (failureCallback != nil) {
				let error: [String:String] = [
					"code": "-1",
					"message": "INVALID_RESPONSE"
				]
				return failureCallback!(error)
			}
		}
	}

	// Callback setter
	func success(callback: ((AnyObject) -> Void)!) -> ThecallrApiRequestHandler {
		self.successCallback = callback
		return self
	}

	func failure(callback: ((AnyObject) -> Void)!) -> ThecallrApiRequestHandler {
		self.failureCallback = callback
		return self
	}

}
