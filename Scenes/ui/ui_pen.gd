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


func _ready():
	$PlayContainer/PlayButton.grab_focus()
	GameStats.money = 10000
	orig_money_label_text = money_label.text
	orig_price_label_text = price_label.text
	_update_money_label()
	GameStats.money_changed.connect(_update_money_label)
	_update_price_label(0)
	_update_description_label("")
	for child: UiShopButton in find_children("*", "UiShopButton"):
		child.mouse_entered.connect(_update_price_label.bind(child.upgrade.cost))
		child.mouse_exited.connect(_update_price_label.bind(0))
		child.mouse_entered.connect(_update_description_label.bind(child.upgrade.description))
		child.mouse_exited.connect(_update_description_label.bind(""))
