extends Panel

var config

# Called when the node enters the scene tree for the first time.
func _ready():
	_loadConfigFromJSON()
	
	# If you really messed up, start new from there and run this only once!
	#Spotify.Auth._delete_token(config.client_id)
	#return
	
	Spotify.Auth.connect("open_authentification_url", self, "_on_open_authentification_url")
	Spotify.Auth.connect("authentification_response_error", self, "_on_spotify_auth_response_error")

	Spotify.Player.connect("response_success", self, "_on_response_success")

	Spotify.configure(config, "StoreItSave!")
	
	if Spotify.Auth.is_authenticated():
		$State.text = "State: Authenticated"

func _on_Authorize_pressed():			
	var scopes = ["user-read-playback-state", "streaming", "user-read-private", "user-follow-modify", "user-library-read", "playlist-modify-public", "user-read-currently-playing", "user-modify-playback-state", "playlist-modify-private"]
	Spotify.Auth.authenticate_start(scopes)	

func _on_AuthorizeCode_pressed():
	Spotify.Auth.connect("authentification_succeeded", self, "_on_authentification_succeeded")
	Spotify.Auth.authentication_code($Code.text)

func _on_open_authentification_url(url):
	print("Open Authentification URL")
	OS.shell_open(url)

func _on_authentification_succeeded():
	print("Authenfication Succeeded")

func _on_spotify_auth_response_error(code, message):
	print_debug(str(code) + " " + message)

func _loadConfigFromJSON():
	var file = File.new()
	var err = file.open("res://spotify-config.json", file.READ)
	if err != OK:
		print("Custom spotify-config not found / Fallback to default")
		err = file.open("res://spotify-config-default.json", file.READ)
		
	if err != OK:
		print("No Spotify Config File Found")
		return

	var json_string = file.get_as_text()
	config = parse_json(json_string)
	print("Loaded Spotify Config")
	print(config)

func _on_response_success(data):
	print("Response Success")
	$Log.text = JSON.print(data)

func _on_GetCurrentPlaybackInformation_pressed():
	Spotify.Player.get_current_playback_information()

func _on_GetCurrentTrack_pressed():
	Spotify.Player.get_current_playing_track()
	
func _on_Play_pressed():
	Spotify.Player.play()

func _on_Pause_pressed():
	Spotify.Player.pause()


func _on_Next_pressed():
	Spotify.Player.next()
