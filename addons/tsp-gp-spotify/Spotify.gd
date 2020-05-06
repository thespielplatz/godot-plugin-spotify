extends Node

var SpotifyAuth = preload("res://addons/tsp-gp-spotify/SpotifyAuth.gd")
var SpotifyPlayer = preload("res://addons/tsp-gp-spotify/SpotifyPlayer.gd")
var SpotifyRequest = preload("res://addons/tsp-gp-spotify/SpotifyRequest.gd")

onready var Auth : SpotifyAuth = SpotifyAuth.new()
onready var Player : SpotifyPlayer = SpotifyPlayer.new()
onready var _spotify_request : SpotifyRequest = SpotifyRequest.new()

signal response_success(data)
signal response_error(code, message)
signal spotify_error(code, message, reason)

func _ready():
	add_child(_spotify_request)
	add_child(Auth)

	_spotify_request.connect("response_success", self, "_on_response_success")
	_spotify_request.connect("response_error", self, "_on_response_error")
	_spotify_request.connect("spotify_error", self, "_on_spotify_error")
	
	Auth.connect("new_access_token", self, "_on_new_access_token")
	Player._http = _spotify_request

func configure(_config : Dictionary, encryption_key : String):
	var config = {
		"client_id" : _config.client_id,
		"client_secret" : _config.client_secret,
		"redirect_uri" : _config.redirect_uri
	}	
	
	Auth.config = config
	Auth.encryption_key = encryption_key
	Auth._load_token()
	
	if Auth.is_authenticated():
		Auth._refresh_token()
		
func is_busy()->bool:
	return _spotify_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED
	
func _on_new_access_token(access_token):
	_spotify_request.access_token = access_token
	
func _on_response_success(data):
	emit_signal("response_success", data)
	
func _on_response_error(code, message):
	emit_signal("response_error", code, message)
	
func _on_spotify_error(code, message, reason):
	emit_signal("spotify_error", code, message, reason)
