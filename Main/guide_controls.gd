extends Node

const Utils = preload("res://Scenes/ui/settings/guide/guide_utils.gd")

@export_group("Context & Modifiers")
@export var controller_axis_invert_modifier:GUIDEModifierNegate
@export var controller_axis_deadzone:GUIDEModifierDeadzone

#@export_group("Actions")
#@export var switch_to_keyboard:GUIDEAction
#@export var switch_to_controller:GUIDEAction

@onready var _remapping_dialog:Control = %RemappingDialog

func _ready() -> void:
	# and switching to controller / keyboard ...
	#switch_to_controller.triggered.connect(_switch.bind(controller))
	#switch_to_keyboard.triggered.connect(_switch.bind(keyboard))

	# Also listen to when the remapping dialog closes and re-apply the changed
	# mapping config
	_remapping_dialog.closed.connect(_load_remapping_config)

	# Start with the keyboard scheme
	#GUIDE.enable_mapping_context(keyboard)

	# finally enable all controls with the last saved remapping configuration
	_load_remapping_config(Utils.load_remapping_config())


func _load_remapping_config(config:GUIDERemappingConfig) -> void:
	GUIDE.set_remapping_config(config)

	# also apply changes to our modifiers
	controller_axis_invert_modifier.x = config.custom_data.get(Utils.CUSTOM_DATA_INVERT_HORIZONTAL, controller_axis_invert_modifier.x)
	controller_axis_invert_modifier.y = config.custom_data.get(Utils.CUSTOM_DATA_INVERT_VERTICAL, controller_axis_invert_modifier.y)

	controller_axis_deadzone.lower_threshold = config.custom_data.get(Utils.CUSTOM_DATA_MOVEMENT_DEADZONE, 0.2)


#func _switch(context:GUIDEMappingContext) -> void:
	## ignore while remapping is active, remapping will take care of it
	#if _remapping_dialog.visible:
		#return
#
	#GUIDE.enable_mapping_context(context, true)
