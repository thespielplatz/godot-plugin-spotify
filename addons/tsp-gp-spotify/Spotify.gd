extends Node

var SpotifyAuth = preload("res://addons/tsp-gp-spotify/SpotifyAuth.gd")
var SpotifyPlayer = preload("res://addons/tsp-gp-spotify/SpotifyPlayer.gd")

onready var Auth : SpotifyAuth = SpotifyAuth.new()
onready var Player : SpotifyPlayer = SpotifyPlayer.new()

#Note: If Web API returns status code 429, it means that you have sent too many requests. When this happens, check the Retry-After header, where you will see a number displayed. This is the number of seconds that you need to wait, before you try your request again.

func _ready():
	add_child(Auth)
	add_child(Player)

	Auth.connect("new_access_token", Player, "_on_new_access_token")

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
