class_name UiPen
extends Control

@onready var upgrade_button: TextureButton = $UpgradeButton
@onready var money_label = %MoneyLabel
@onready var price_label = %PriceLabel
@onready var description_label = %DescriptionLabel

var orig_money_label_text: String
var orig_price_label_text: String

func _update_button_enablement() -> void:
	if not DeerUpgrades.upgrade_available_for_purchase():
		upgrade_button.queue_free()


func _on_play_button_pressed() -> void:
	GameState.current = GameState.State.PLAY


func _on_upgrade_button_pressed() -> void:
	DeerUpgrades.increment_upgrade()
	_update_button_enablement()


func _update_money_label():
	var count = GameStats.money
	money_label.text = orig_money_label_text.replace("{0}", str(count))


func _update_price_label(current_price: int):
	print("Update price label: %s" % current_price)
	price_label.visible = current_price > 0
	price_label.text = orig_price_label_text.replace("{0}", str(current_price))


func _update_description_label(description: String):
	description_label.visible = description != ""
	description_label.text = description

func _update_labels(upgrade: UpgradeStats):
	_update_description_label(upgrade.description if upgrade else "")
	_update_price_label(upgrade.cost if upgrade else 0)


func _ready():
	orig_money_label_text = money_label.text
	orig_price_label_text = price_label.text
	_update_money_label()
	GameStats.money_changed.connect(_update_money_label)
	_update_price_label(0)
	_update_description_label("")
	for button: UiShopButton in find_children("*", "UiShopButton"):
		button.enabled_changed.connect(_on_button_enabled)
		button.focus_entered.connect(_update_labels.bind(button.upgrade))
		button.focus_exited.connect(_update_labels.bind(null))
		button.mouse_entered.connect(_update_labels.bind(button.upgrade))
		button.mouse_exited.connect(_update_labels.bind(null))


func _on_button_enabled(button: UiShopButton, enabled: bool):
	if enabled:
		var path :=  %PlayButton.get_path_to(button)
		%PlayButton.focus_neighbor_left = path
		%PlayButton.focus_neighbor_right = path
		%PlayButton.focus_neighbor_top = path
		%PlayButton.focus_neighbor_bottom = path


func _on_visibility_changed() -> void:
	$Shop.set_camera_position()
	if visible:
		%PlayButton.grab_focus()
