extends HTTPRequest
class_name SpotifyPlayer

signal response_success(data)
signal response_error(code, message)

const url_get_current_playing_track = "https://api.spotify.com/v1/me/player/currently-playing"
const url_get_current_playback_information = "https://api.spotify.com/v1/me/player"
const url_play = "https://api.spotify.com/v1/me/player/play"
const url_pause = "https://api.spotify.com/v1/me/player/pause"
const url_next = "https://api.spotify.com/v1/me/player/next"
const url_set_volume = "https://api.spotify.com/v1/me/player/volume"

onready var http_client = HTTPClient.new() # Create the Client.
var access_token

func _on_new_access_token(_access_token):
	access_token = _access_token

func _ready():
	connect("request_completed", self, "_on_request_completed")
	
func get_current_playback_information():
	_send_request(url_get_current_playback_information, HTTPClient.METHOD_GET)	
	
func get_current_playing_track():
	_send_request(url_get_current_playing_track, HTTPClient.METHOD_GET)	

func play():
	_send_request(url_play, HTTPClient.METHOD_PUT)	

func pause():
	_send_request(url_pause, HTTPClient.METHOD_PUT)	

func next():
	_send_request(url_next, HTTPClient.METHOD_POST)	

func set_volume(volume_percent : int):
	_send_request(url_set_volume, HTTPClient.METHOD_PUT, {
		"volume_percent" : volume_percent
	})

func _send_request(url, method, fields := {}):
	var query_string = http_client.query_string_from_dict(fields)
	var headers = ["Authorization: Bearer " + access_token, "Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(query_string.length())]
	request(url, headers, true, method, query_string)	

func _on_request_completed(result, response_code, headers, body):
	if response_code == HTTPClient.RESPONSE_NO_CONTENT:
		emit_signal("response_success", "")
		return
		
	var body_string = body.get_string_from_utf8()
	var json_result = JSON.parse(body_string)
	
	if json_result.error != OK:
		print_debug("Error while parsing body json")
		print_debug("ResponseCode: " + str(response_code) + "\nBody:\n" + body_string)
		emit_signal("response_error", -1, "Error Parsing JSON")
		return
	
	var res = json_result.result
	
	# See: https://developer.spotify.com/documentation/web-api/
	if response_code >= HTTPClient.RESPONSE_OK && response_code < HTTPClient.RESPONSE_MULTIPLE_CHOICES: 
		emit_signal("response_success", res)
	else:
		emit_signal("response_error", response_code, body_string)
