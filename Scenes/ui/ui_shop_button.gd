
class_name UiShopButton
extends TextureRect



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

@onready var button: TextureButton = get_child(0)

func _ready() -> void:
	button.modulate = COLOR_DISABLED
	tooltip_text = DeerUpgrades.Category.find_key(id)
	button.pressed.connect(_on_pressed)
	DeerUpgrades.upgrades_updated.connect(_on_updated_upgrades)
	if id == DeerUpgrades.Category.SMALL_ANTLERS:
		current_StoreState = StoreState.ENABLED
	check_status()

func check_status():
	match current_StoreState:
		StoreState.ENABLED:
			button.modulate = COLOR_ENABLED
			button.disabled = false
		StoreState.DISABLED:
			button.modulate = COLOR_DISABLED
			button.disabled = true
		StoreState.PURCHASED:
			button.modulate = COLOR_PURCHASED
			button.disabled = true

func _on_pressed() -> void:
	current_StoreState = StoreState.PURCHASED
	DeerUpgrades.increment_upgrade()
	check_status()

func _on_updated_upgrades() -> void:
	print("A")
	if DeerUpgrades.get_next_upgrade() == id:
		current_StoreState = StoreState.ENABLED
