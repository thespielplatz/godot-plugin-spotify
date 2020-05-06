extends Node
class_name SpotifyPlayer

var _http : SpotifyRequest

const url_get_devices = "https://api.spotify.com/v1/me/player/devices"
const url_transfer_playback = "https://api.spotify.com/v1/me/player"
const url_get_current_playing_track = "https://api.spotify.com/v1/me/player/currently-playing"
const url_get_current_playback_information = "https://api.spotify.com/v1/me/player"
const url_play = "https://api.spotify.com/v1/me/player/play"
const url_pause = "https://api.spotify.com/v1/me/player/pause"
const url_next = "https://api.spotify.com/v1/me/player/next"
const url_set_volume = "https://api.spotify.com/v1/me/player/volume"

func _ready():
	pass

func get_devices(callback : FuncRef = null):
	_http.send_request(url_get_devices, HTTPClient.METHOD_GET, {}, callback)

func transfer_playback(deviceId : String, play : bool, callback : FuncRef = null):
	_http.send_request(url_transfer_playback, HTTPClient.METHOD_PUT, { 
		"device_ids" : [deviceId],
		"play" : play
	}, callback)

func get_current_playback_information(callback : FuncRef = null):
	_http.send_request(url_get_current_playback_information, HTTPClient.METHOD_GET, {}, callback)
	
func get_current_playing_track(callback : FuncRef = null):
	_http.send_request(url_get_current_playing_track, HTTPClient.METHOD_GET, {}, callback)

func play():
	_http.send_request(url_play, HTTPClient.METHOD_PUT)

func pause():
	_http.send_request(url_pause, HTTPClient.METHOD_PUT)

func next():
	_http.send_request(url_next, HTTPClient.METHOD_POST)

func set_volume(volume_percent : int):
	var url = url_set_volume + "?volume_percent=" + str(volume_percent)
	if _http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		_http.send_request(url, HTTPClient.METHOD_PUT)
	else:
		_http.last_request(url, HTTPClient.METHOD_PUT)
	
