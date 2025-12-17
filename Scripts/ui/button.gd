extends Node


func _ready():
	connect("mouse_entered", func():
		GlobalAudioPlayer.playlist["UI"]["Hover"].play()
	)
	connect("pressed", func():
		GlobalAudioPlayer.playlist["UI"]["Click1"].play()
	)
