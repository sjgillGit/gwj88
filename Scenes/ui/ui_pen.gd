class_name UiPen
extends Control

@onready var upgrade_button: TextureButton = $UpgradeButton
@onready var money_label = %MoneyLabel

var orig_money_label_text: String

func _update_button_enablement() -> void:
	if not DeerUpgrades.upgrade_available_for_purchase():
		upgrade_button.queue_free()


func _on_play_button_pressed() -> void:
	GameState.current = GameState.State.PLAY


func _on_upgrade_button_pressed() -> void:
	DeerUpgrades.increment_upgrade()
	_update_button_enablement()


func _update_money_label():
	var count = GameState.money
	money_label.text = orig_money_label_text.replace("{0}", str(count))


func _ready():
	orig_money_label_text = money_label.text
	_update_money_label()
	GameState.money_changed.connect(_update_money_label)
