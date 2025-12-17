extends Node

signal upgrades_updated

enum Category {
	# do not reorder, all our values set in the editor will shuffle!
	NONE,
	BASE,
	SMALL_ANTLERS,
	LARGE_ANTLERS,
	DECORATED_ANTLERS,
	COLLAR,
	SADDLE,
	ELF,
	ROCKETS,
	WINGS,
	# HEAD, # Todo with assets, frosty hat, glasses, nose
	# SLED, # Todo
	# TRAIL, # Todo with assets, rainbow road
}

# Because categories are just an int.. if we mess with the
# order of the ENUM then all our values will shuffle...
# safer to have an array for the order
const _upgrade_order: Array[Category] = [
	Category.SMALL_ANTLERS,
	Category.LARGE_ANTLERS,
	Category.DECORATED_ANTLERS,
	Category.COLLAR,
	Category.SADDLE,
	Category.ELF,
	Category.ROCKETS,
	Category.WINGS
];

var _upgrades: Array[Category] = [Category.BASE]


func increment_upgrade():
	for upgrade in _upgrade_order:
		if upgrade == DeerUpgrades.Category.NONE || upgrade in _upgrades:
			continue
		_upgrades.append(upgrade)
		print("Adding upgrade: %s" % Category.keys()[upgrade])
		upgrades_updated.emit()
		break


func upgrade_available_for_purchase() -> bool:
	return len(_upgrades) < len(Category.keys())


func get_upgrades() -> Array[Category]:
	return _upgrades
