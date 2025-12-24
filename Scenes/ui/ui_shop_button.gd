
class_name UiShopButton
extends Button

signal enabled_changed(button: UiShopButton, enabled: bool)

const COLOR_DISABLED: Color = Color()
const COLOR_ENABLED: Color = Color("ffffff")
const COLOR_PURCHASED: Color = Color.DIM_GRAY

enum StoreState{
	ENABLED,
	DISABLED,
	PURCHASED,
}

@export var id: DeerUpgrades.Category = DeerUpgrades.Category.NONE
var current_StoreState: StoreState = StoreState.DISABLED:
	set(v):
		current_StoreState = v
		check_status()

@export var upgrade: UpgradeStats

@onready var button: TextureRect = get_child(0)

func _ready() -> void:
	disabled = true
	button.modulate = COLOR_DISABLED
	tooltip_text = "" #DeerUpgrades.Category.find_key(id)
	pressed.connect(_on_pressed)
	DeerUpgrades.upgrades_updated.connect(_on_updated_upgrades)
	if id == DeerUpgrades.Category.SMALL_ANTLERS:
		current_StoreState = StoreState.ENABLED
	check_status()


func check_status():
	match current_StoreState:
		StoreState.ENABLED:
			button.modulate = COLOR_ENABLED
			disabled = false

		StoreState.DISABLED:
			button.modulate = COLOR_DISABLED
			disabled = true
		StoreState.PURCHASED:
			button.modulate = COLOR_PURCHASED
			disabled = true
	enabled_changed.emit(self, !disabled)

func _on_pressed() -> void:
	if DeerUpgrades.increment_upgrade():
		current_StoreState = StoreState.PURCHASED
	check_status()

func _on_updated_upgrades() -> void:
	if DeerUpgrades.get_next_upgrade() == id:
		current_StoreState = StoreState.ENABLED
	check_status()
