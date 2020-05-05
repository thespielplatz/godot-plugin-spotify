extends HTTPRequest
class_name SpotifyRequest

signal response_success(data)
signal response_error(code, message)

var access_token : String

var _http_helper : HTTPClient = HTTPClient.new()
var _callback : FuncRef = null
var _last_request = null

func _ready():
	connect("request_completed", self, "_on_request_completed")
	pass # Replace with function body.

func send_request(url, method, fields := {}, callback : FuncRef = null):
	var query_string = _http_helper.query_string_from_dict(fields)
	var headers = ["Authorization: Bearer " + access_token, "Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(query_string.length())]
	var status = request(url, headers, true, method, query_string)
	if status == OK:
		_callback = callback

	return status
	
func last_request(url, method, fields := {}, callback : FuncRef = null):
	_last_request = {
		"url" : url,
		"method" : method,
		"fields" : fields,
		"callback" : callback
	}
	
func _on_request_completed(result, response_code, headers, body):
	if response_code == HTTPClient.RESPONSE_NO_CONTENT:
		emit_signal("response_success", "")
		if _callback != null:
			_callback.call_func(body)
			_callback = null
			
		if _last_request != null:
			send_request(_last_request.url, _last_request.method, _last_request.fields, _last_request.callback)
			_last_request = null
			
		return
		
	var body_string = body.get_string_from_utf8()
	var json_result = JSON.parse(body_string)
	
	if json_result.error != OK:
		_last_request = null
		_callback = null
		print_debug("Error while parsing body json")
		print_debug("ResponseCode: " + str(response_code) + "\nBody:\n" + body_string)
		emit_signal("response_error", -1, "Error Parsing JSON")
		return
	
	var res = json_result.result
	
	# See: https://developer.spotify.com/documentation/web-api/
	if response_code >= HTTPClient.RESPONSE_OK && response_code < HTTPClient.RESPONSE_MULTIPLE_CHOICES: 
		emit_signal("response_success", res)
		
		if _callback != null:
			var b = _callback.is_valid()
			_callback.call_func(res)
			_callback = null
			
		if _last_request != null:
			send_request(_last_request.url, _last_request.method, _last_request.fields, _last_request.callback)
			_last_request = null
			
	else:
		emit_signal("response_error", response_code, body_string)
