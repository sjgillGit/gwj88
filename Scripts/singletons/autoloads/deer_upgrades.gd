extends Node

signal upgrades_updated

# stretch: Everything is upgradable!
# antlers can be scaled to get incrementally better
# rockets get more fuel
# collar jingles louder and gets flashing lights?
# antler decorations: upgrade to add one ball at a time
# wings get bigger
enum Category {
	# do not reorder, all our values set in the editor will shuffle!
	NONE=-1,
	# missing entries for backward compatibility
	SMALL_ANTLERS=2,
	ROCKETS=8,
	COLLAR=5,
	WINGS=9,
	LARGE_ANTLERS=3,
	DECORATED_ANTLERS=4
	# stretch: upgrade rockets
	# RAMP BOOSTERS # add boosters to the ramp to launch faster
	# CHRISTMAS_MAGIC # magic christmas dust, you can just run on air infinitely, cancels wings and rockets
}

# Because categories are just an int.. if we mess with the
# order of the ENUM then all our values will shuffle...
# safer to have an array for the order
const _upgrade_order: Array[Category] = [
	Category.SMALL_ANTLERS,
	Category.ROCKETS,
	Category.COLLAR,
	Category.WINGS,
	Category.LARGE_ANTLERS,
	Category.DECORATED_ANTLERS
];

var _upgrades: Array[Category] = []


func increment_upgrade():
	for upgrade in _upgrade_order:
		if upgrade == DeerUpgrades.Category.NONE || upgrade in _upgrades:
			continue
		_upgrades.append(upgrade)
		print("Adding upgrade: %s" % Category.find_key(upgrade))
		upgrades_updated.emit()
		break


func upgrade_available_for_purchase() -> bool:
	return len(_upgrades) < len(_upgrade_order)


func get_upgrades() -> Array[Category]:
	return _upgrades
