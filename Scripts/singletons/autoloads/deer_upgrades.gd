class_name DeerUpgrades
extends RefCounted

enum Category {
	BASE,
	SMALL_ANTLERS,
	LARGE_ANTLERS,
	DECORATED_ANTLERS,
	SADDLE,
	ELF,
	WINGS,
	ROCKETS,
	COLLAR,
	# HEAD, # Todo with assets, frosty hat, glasses, nose
	# SLED, # Todo
	# TRAIL, # Todo with assets, rainbow road
}

static var _upgrades: Array[Category]


static func set_upgrade(category: Category):
	_upgrades.append(category)


static func get_upgrades():
	return _upgrades
