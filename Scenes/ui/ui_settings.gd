
class_name UiSettings
extends Control

@onready var _remapping_dialog:Control = %RemappingDialog
@onready var _settings_panel_container: PanelContainer = %SettingsPanelContainer

func _on_back_pressed() -> void:
	GameState.current = GameState.State.MAIN_MENU


func _on_setting_2_pressed() -> void:
	pass


func _on_setting_1_pressed() -> void:
	_settings_panel_container.hide()
	_remapping_dialog.open()
	_remapping_dialog.closed.connect(_on_remapping_closed)

func _on_remapping_closed(applied_config:GUIDERemappingConfig) -> void:
	_settings_panel_container.show()
	%ControlsButton.grab_focus()

func _on_vsync_pressed() -> void:
	var toggled_on = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_ENABLED
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)
	%Vsync/Label.text = 'vsync %s' % ["☐" if !toggled_on else "☑"]

func _on_visibility_changed() -> void:
	if visible:
		%ControlsButton.grab_focus()
