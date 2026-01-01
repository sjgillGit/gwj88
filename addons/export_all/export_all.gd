@tool
extends EditorPlugin

var _button: Button
var _version: LineEdit
var _label: Label

func _enter_tree() -> void:
	_label = Label.new()
	_label.text = "|  v"
	_button = Button.new()
	_button.text = "Export All"
	_button.pressed.connect(_do_export)
	_version = LineEdit.new()
	_version.placeholder_text = "version"
	var es := EditorInterface.get_editor_settings()
	var version = es.get("application/config/version")
	_version.text = version if version else ""
	_version.text_changed.connect(_on_version_changed)
	var erb = EditorInterface.get_base_control().find_child("@EditorRunBar@*", true, false)
	var hbox = erb.find_child("@HBoxContainer@*", true, false)
	hbox.add_child(_label)
	hbox.add_child(_version)
	hbox.add_child(_button)

func _on_version_changed(text: String):
	var es := EditorInterface.get_editor_settings()
	es.set_setting("application/config/version", text)


func _do_export():
	var cfg := ConfigFile.new()
	var cfg_path := "res://export_presets.cfg"
	cfg.load(cfg_path)
	var platforms: Array[String]
	for section in cfg.get_sections():
		if section.ends_with(".options"):
			continue
		var name := cfg.get_value(section, "name")
		if name.to_lower() == 'web':
			continue
		platforms.append(name)
		print("Exporting %s" % [name])
		# temp just do the first one
	cfg.save(cfg_path)
	var args := ["--headless", "--export-release"]
	for p_name in platforms:
		await get_tree().process_frame
		var execute_path := OS.get_executable_path()
		var ext := {
			windows= '/Ringo learns to fly.exe',
			linux= '/Ringo learns to fly.x86_64',
			macos= '.zip'
		}
		var p_path := "exports/Ringo learns to fly %s %s"
		var p_key := p_name.split(" ")[0].to_lower()
		p_path = p_path % [p_key, _version.text]
		if ext[p_key].begins_with("/"):
			var d := DirAccess.open("res://")
			if !d:
				printerr("Error opening dir at %s : %s" % [
					p_path, DirAccess.get_open_error()
				])
				return
			var abs_dir := d.get_current_dir().path_join(p_path)
			print("Making dir: %s" % [abs_dir])
			var err := DirAccess.make_dir_recursive_absolute(abs_dir)
			if err != OK:
				printerr("Error making %s: %s" % [abs_dir, err])
				return
		var p_exe = "%s%s" % [p_path, ext[p_key]]
		var p_args = args.duplicate()
		p_args.append_array([p_name, p_exe])
		print("Exporting '%s' (please be patient)" % [p_exe])
		await get_tree().process_frame
		var output := []
		var exit_code = OS.execute(execute_path, p_args, output, true, true)
		if "\n".join(output).contains("BACKTRACE"):
			printerr(output)
			return
		# print(output)
		print("Packing '%s' > '%s.zip'" % [p_path, p_path])
		await get_tree().process_frame
		var zip_path = p_exe
		if !p_exe.ends_with(".zip"):
			zip_path = "%s.zip" % [p_path]
			var err := write_zip_file(p_path, zip_path)
			if err != OK:
				print("Error packing %s: %s" % [p_path, err])
		print("Done packing %s to '%s'" % [p_name, zip_path])

# Create a ZIP archive with a single file at its root.
func write_zip_file(dir_path: String, zip_filename: String) -> int:
	var writer = ZIPPacker.new()
	var err = writer.open(zip_filename)
	if err != OK:
		return err
	var root = DirAccess.open(dir_path)
	if !root:
		printerr("Error opening %s : %s" % [
			dir_path, DirAccess.get_open_error()
		])
		return DirAccess.get_open_error()
	err = pack_dir(writer, root, dir_path.get_file())
	writer.close()
	if err != OK:
		return err
	return OK


func pack_dir(p: ZIPPacker, d: DirAccess, zip_path: String) -> int:
	for f_name in d.get_files():
		var d_path := d.get_current_dir()
		var f_path := d_path.path_join(f_name)
		var zf_path := zip_path.path_join(f_name)
		var f := FileAccess.open(f_path, FileAccess.READ)
		if !f:
			p.close
			printerr("Error opening %s : %s" % [f_path, FileAccess.get_open_error()])
			return FileAccess.get_open_error()
		p.start_file(zf_path)
		var bytes := PackedByteArray()
		while true:
			bytes = f.get_buffer(8192)
			if len(bytes) == 0:
				break
			p.write_file(bytes)
		p.close_file()
	for d_name in d.get_directories():
		printerr("subdirectories not supported")
		return 1
	return OK

func _exit_tree() -> void:
	_button.queue_free()
	_version.queue_free()
	_label.queue_free()
	_button = null
	_version = null
	_label = null
