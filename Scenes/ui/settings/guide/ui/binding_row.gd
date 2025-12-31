extends PanelContainer

signal rebind(item:GUIDERemapper.ConfigItem)

@onready var _action_name:Label = %ActionName
@onready var binding_row:HBoxContainer = %BindingRow
@onready var _button: Button = $Button

var bindings:Array[Control] = []

var _item:GUIDERemapper.ConfigItem

func initialize(display_name:String) -> void:
	_action_name.text = display_name

func _on_texture_button_pressed() -> void:
	if bindings.size() > 0:
		bindings[0].do_rebind()

func add(node:GUIDEActionBinding) -> void:
	binding_row.add_child(node)
	if bindings.size() == 0:
		_button.focus_neighbor_right = node.button.get_path()
	else:
		bindings[bindings.size() - 1].button.focus_neighbor_right = node.button.get_path()
	bindings.append(node)
