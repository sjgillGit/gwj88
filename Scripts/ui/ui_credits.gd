
class_name UiCredits
extends Control

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var rich_text: RichTextLabel = $RichTextLabel


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"scroll":
			GameState.current = GameState.State.MAIN_MENU


func _on_visibility_changed() -> void:
	if not anim_player or not rich_text:
		return
	if visible:
		anim_player.play("scroll")
		GlobalAudioPlayer.playlist["UI"]["Egg"].play()
	else:
		GlobalAudioPlayer.playlist["UI"]["Egg"].stop()
		rich_text.position = Vector2.ZERO
