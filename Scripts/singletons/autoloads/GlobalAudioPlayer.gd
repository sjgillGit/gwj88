
#class_name GlobalAudioPlayer
extends Node

@onready var playlist: Dictionary = {
	"UI": {
		"Click1": $UI/Click1,
		"Click2": $UI/Click2,
		"Hover": $UI/Hover,
		"Egg": $UI/Egg,
		},

	"PLAYER": $PLAYER,

	"ENVIRONMENT": $ENVIRONMENT,
	}
