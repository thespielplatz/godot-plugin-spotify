extends HTTPRequest
class_name SpotifyAuth

const file_dir = "user://plugin-spotify/"
const file_path_template = "user://plugin-spotify/#client_id#-tokens.save"

const url_token_api = "https://accounts.spotify.com/api/token"

signal open_authentification_url(url)

signal authentification_response_error(code, message)
signal authentification_succeeded(auth)
signal new_access_token(token)

# Added Throug Auth: access_token, token_type, refresh_token
var config = {}

var encryption_key = ""
var auth_code = ""
var refresh_running = false
onready var http_client = HTTPClient.new() # Create the Client.


func _ready():
	connect("request_completed", self, "_on_request_completed")

func is_authenticated()->bool:
	return config != null && config.has("refresh_token")
	
func authenticate_start(scopes : Array):
	var url = "https://accounts.spotify.com/authorize?client_id="
	url += config.client_id
	url += "&response_type=code&redirect_uri="
	url += config.redirect_uri
	url += "&scope="
	url += _arr_join(scopes, " ")
	emit_signal("open_authentification_url", url)
	
func authentication_code(code : String):
	refresh_running = false
	
	# Clear Config, but don't loose reference
	var client_id = config.client_id
	var client_secret = config.client_secret
	var redirect_uri = config.redirect_uri
	
	config.clear()
	config.client_id = client_id
	config.client_secret = client_secret
	config.redirect_uri = redirect_uri

	_save_token()
	
	var fields = {
		"client_id" : config.client_id,
		"client_secret" : config.client_secret,
		"redirect_uri" : config.redirect_uri,
		"grant_type" : "authorization_code",
		"code" : code
	}
	
	var query_string = http_client.query_string_from_dict(fields)
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(query_string.length())]
	
	request(url_token_api, headers, true, HTTPClient.METHOD_POST, query_string)

func _start_refresh_token_countdown():
	if refresh_running:
		return
		
	refresh_running = true
	
	var expires_in = config.expires_in
	
	yield(get_tree().create_timer(float(expires_in)), "timeout")
	_refresh_token()
	
func _refresh_token():
	#print("Refreshing Spotify API Token")
	refresh_running = false
	
	var fields = {
		"client_id" : config.client_id,
		"client_secret" : config.client_secret,
		"grant_type" : "refresh_token",
		"refresh_token" : config.refresh_token
	}
	
	var query_string = http_client.query_string_from_dict(fields)
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(query_string.length())]
	
	request(url_token_api, headers, true, HTTPClient.METHOD_POST, query_string)
	
func _on_request_completed(result, response_code, headers, body):
	var body_string = body.get_string_from_utf8()
	var json_result = JSON.parse(body_string)
	
	if json_result.error != OK:
		print_debug("Error while parsing body json")
		print_debug(body_string)
		emit_signal("authentification_response_error", -1, "Error Parsing JSON")
		return
	
	var res = json_result.result
	
	# See: https://developer.spotify.com/documentation/web-api/
	if response_code >= HTTPClient.RESPONSE_OK && response_code < HTTPClient.RESPONSE_MULTIPLE_CHOICES: # (300)
		config.access_token = res.access_token
		config.token_type = res.token_type
		config.expires_in = res.expires_in
		
		# only set at authentification
		if res.has("refresh_token"):
			config.refresh_token = res.refresh_token
		_save_token()
	
		_start_refresh_token_countdown()
		
		# only signal at authentification
		if res.has("refresh_token"):
			emit_signal("authentification_succeeded")
		
		emit_signal("new_access_token", config.access_token)
	else:
		emit_signal("authentification_response_error", response_code, body_string)

func _load_token():
	var dir = Directory.new()
	if not dir.dir_exists(file_dir):
		var err = dir.make_dir_recursive(file_dir)
		if err:
			print_debug(err)
		return

	var file_path = file_path_template.replace("#client_id#", config.client_id)
	var file = File.new()
	if not file.file_exists(file_path):
		return

	var err = file.open_encrypted_with_pass(file_path, File.READ, encryption_key)
	if err:
		return

	var config_string = file.get_as_text()
	file.close()
	
	if config_string != null && config_string != "":
		var json_result = JSON.parse(config_string)
		
		if json_result.error != OK:
			print_debug("Error while parsing json from file - deleting config - reauth please")
			return
		
		config = json_result.result

func _delete_token(client_id):
	var file_path = file_path_template.replace("#client_id#", client_id)
	var dir = Directory.new()
	if not dir.file_exists(file_path):
		return

	dir.remove(file_path)
	
func _save_token():
	var dir = Directory.new()
	if not dir.dir_exists(file_dir):
		var err = dir.make_dir_recursive(file_dir)
		if err:
			print_debug(err)
		return
			
	var file_path = file_path_template.replace("#client_id#", config.client_id)
	var file = File.new()
	
	var err = file.open_encrypted_with_pass(file_path, File.WRITE, encryption_key)
	if err:
		print_debug(err)
		
	file.store_string(JSON.print(config))
	file.close()
	
func _arr_join(arr, separator = ""):
	var output = "";
	for s in arr:
		output += str(s) + separator
	output = output.left( output.length() - separator.length() )
	return output
