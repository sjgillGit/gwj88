
## If you need to load something, place it here.
class_name GlobalPreLoader
extends ResourcePreloader


func _ready() -> void:
	add_resource(&"MAIN_MENU", preload("uid://c1ramn8byuilg"))
	add_resource(&"PLAY", preload("uid://x2y5w8pwjbrc"))
	add_resource(&"SETTINGS", preload("uid://brl11g3oxo4y1"))
	add_resource(&"CREDITS",preload("uid://c7rtap1601thy"))
