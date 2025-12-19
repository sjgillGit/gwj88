

class_name UiShop
extends Control

const POSITION_STARTING: Vector2 = Vector2(5.0, 2.0)
const POSITION_FINAL: Vector2 = Vector2(-222.0, 2.0)

var tween: Tween

func _ready() -> void:
	_return_to_start()

func _return_to_start() -> void:
	if tween:
		tween.kill()
	position = POSITION_STARTING


func _on_ui_pen_visibility_changed() -> void:
	if position != POSITION_STARTING:
		_return_to_start()
	if visible:
		tween = create_tween()
		tween.tween_property(self, "position", POSITION_FINAL, 1.16).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
