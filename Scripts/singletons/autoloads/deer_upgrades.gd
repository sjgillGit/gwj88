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


static func increment_upgrade():
	for upgrade in DeerUpgrades.Category.values():
		if upgrade in _upgrades:
			continue
		_upgrades.append(upgrade)
		print("Adding upgrade: %s" % Category.keys()[upgrade])
		break


static func upgrade_available_for_purchase() -> bool:
	return len(_upgrades) < len(Category.keys())


#static func set_upgrade(category: Category):
	#print("Adding upgrade: %s" % Category.keys()[category])
	#_upgrades.append(category)


static func get_upgrades():
	return _upgrades
