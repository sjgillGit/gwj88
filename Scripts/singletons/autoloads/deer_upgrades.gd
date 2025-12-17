extends Node

signal upgrades_updated

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

var _upgrades: Array[Category] = [Category.BASE]


func increment_upgrade():
	for upgrade in DeerUpgrades.Category.values():
		if upgrade in _upgrades:
			continue
		_upgrades.append(upgrade)
		print("Adding upgrade: %s" % Category.keys()[upgrade])
		upgrades_updated.emit()
		break


func upgrade_available_for_purchase() -> bool:
	return len(_upgrades) < len(Category.keys())


func get_upgrades():
	return _upgrades
