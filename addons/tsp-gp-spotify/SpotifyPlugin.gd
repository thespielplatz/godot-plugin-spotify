tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("Spotify", "res://addons/tsp-gp-spotify/Spotify.gd")

func _exit_tree():
	remove_autoload_singleton("Spotify")
