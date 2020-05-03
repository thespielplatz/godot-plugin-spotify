# Spotify Plugin for Godot 3.x
A godot plugin to control spotify

I will implement the features on the way, as I need them or they are requested by the community

Did you use my code and and it worked without problems? You could ...<br>
<a href='https://ko-fi.com/T6T31O7TS' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=2' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

WIP: https://patreon.com/

### Implemented
- Auth
- Player
	- Get Information About The User's Current Playback
	- Get Current Track
	- Play
	- Pause
	- Next
	- Set Volume

## Install

1. Copy the folder **addons/tsp-gp-spotify** to the project path res://addons/
2. Open your Project Settings
3. Go to Plugins
4. Activate the TSP GP Spotify
5. From there, you will have an autoload singleton with the variables 

## Configuration

1. goto https://developer.spotify.com/ amd create new Spotify App
2. Add Redirect URI in Spotify
3. You need to configure the Spotify Plugin. The encryption_key is to save the access tokens of Spotify savely._

'''
var enrcyption_key = "SOME_STATIC_KEY_"
{
	 "client_id" : "",
	 "client_secret" : "",
	 "redirect_uri" : ""
}

Spotify.configure(config, enrcyption_key)
'''

4. If you start authenticating you need to tell, which scopes you wanna use: 
	- Scopes: https://developer.spotify.com/documentation/general/guides/scopes/
'''
var scopes = ["user-read-playback-state", "user-modify-playback-state"]
Spotify.Auth.authenticate_start(scopes)	
'''

	- which triggers a _on_open_authentification_url signal

### How To
Check out the playground code

### Tips

- if you messed up alot, clear the token
'''
Spotify.Auth._delete_token(client_id)
'''

