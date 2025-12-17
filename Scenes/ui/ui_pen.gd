class_name UiPen
extends Control

@onready var upgrade_button: TextureButton = $UpgradeButton


func _update_button_enablement() -> void:
	if not DeerUpgrades.upgrade_available_for_purchase():
		upgrade_button.queue_free()


func _on_play_button_pressed() -> void:
	GameState.current = GameState.State.PLAY


func _on_upgrade_button_pressed() -> void:
	DeerUpgrades.increment_upgrade()
	_update_button_enablement()
