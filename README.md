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
	- Nextsp
	- Set Volume
	- Get a User's Available Devices
	- Transfer a User's Playback

## Install

1. Copy the folder **addons/tsp-gp-spotify** to the project path res://addons/
2. Open your Project Settings
3. Go to Plugins
4. Activate the TSP GP Spotify
5. From there, you will have an autoload singleton with the variables 

## Spotify App

1. Goto https://developer.spotify.com/ register
2. At the Dashboard "CREATE A CLIENT ID"
3. Save the ClientId and ClientSecret
4. Goto your App and "Edit Settings"
5. Add Redirect URI in Spotify --> you have to choose one

## Configure the Plugin
1. You need to configure the Spotify Plugin with the id, secret, url and an encrption key. The encryption_key is to save the access tokens of Spotify encrypted.

```python
var enrcyption_key = "SOME_STATIC_KEY_IF_CHANGE_THAT_YOUR_TOKENS_WILL_BE_DELETE_AND_YOU_SHALL_NOT_PASS"
{
	 "client_id" : "",
	 "client_secret" : "",
	 "redirect_uri" : ""
}

Spotify.configure(config, enrcyption_key)
```

2. During authenticating you need to tell, which scopes you wanna use: 
	- Scopes: https://developer.spotify.com/documentation/general/guides/scopes/
```python
var scopes = ["user-read-playback-state", "user-modify-playback-state"]
Spotify.Auth.authenticate_start(scopes)	
```

3. authenticate_start(scopes) triggers a _on_open_authentification_url(url) signal
4. open the url in your browser
5. accept or don't accept and shut down your computer
6. the browser redirects to your redirect_uri and there is a code parameter in your url
7. use the code to get the first access token

```python
var code = "thecodeyoucopiedfromtheredirectedurlandyoushallpass"
Spotify.Auth.authentication_code(code)
```

8. good to go ... I think ... or there is a bug ;)

## How To
Check out the playground code

## Signals

####  Spotify has three signals:

The Request was a success
```python
signal response_success(data)
```

There was an error with the underlying http request
```python
signal response_error(code, message)
```
The Spotify Web API states an error. e.g. NO_ACTIVE_PLAYER --> this causes an 404 Response
```python
signal spotify_error(code, message, reason)
```

- The Spotify Plugin has three signals:

#### Spotify.Auth
Give the Spotify App access to your spotify account
```python
signal open_authentification_url(url)
```

Successfully Authenticated the app
```python
signal authentification_succeeded(auth)
```

There was an error (http request or spotify api)
```python
signal authentification_response_error(code, message)
```

- if you messed up alot, clear the token
```python
Spotify.Auth._delete_token(client_id)
```

- The Plugin is single HTTP based, this means as long as one command is executed, no other can be sent (and will be ignored). You can check the status with:
```python
func _on_GetCurrentTrack_pressed():
	if !Spotify.is_busy():
		Spotify.Player.get_current_playing_track()
```

- You sometimes you don't need the request data, you just fire the requests
```python
Spotify.Player.play()
```

- ... but if you want to have a toggle play/pause you need some info before. I created callbacks with funcref for that. Still not sure if this is the best solution
```python
func _on_PlayPause_pressed():
	Spotify.Player.get_current_playback_information(funcref(self, "_on_playback_response"))

func _on_playback_response(data):
	print("Playback Info for Toggle")
	if data.is_playing:
		Spotify.Player.pause()
	else:
		Spotify.Player.play()

```

