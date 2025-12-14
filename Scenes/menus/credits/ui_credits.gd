
class_name UiCredits
extends Control

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.play("scroll")
	GlobalAudioPlayer.playlist["UI"]["Egg"].play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"scroll":
			GlobalAudioPlayer.playlist["UI"]["Egg"].stop()
			RootNode.root_ref.current_mode = RootNode.root_ref.GameMode.MAIN_MENU
