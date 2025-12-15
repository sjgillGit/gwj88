class_name Stat extends Resource

@export var _name: StringName
@export var _value: Variant

@export var _max_upgrades: int
@export var _current_upgrade := 0
@export var _value_increase: Variant

@export var _upgrade_cost: int
@export var _cost_increase: int


func _init(
	name_: StringName,
	value_: Variant,
	max_upgrades,
	value_increase: Variant,
	upgrade_cost_: int,
	cost_increase: int
) -> void:
	_name = name_
	_value = value_
	_max_upgrades = max_upgrades
	_value_increase = value_increase
	_upgrade_cost = upgrade_cost_
	_cost_increase = cost_increase


# TODO: get the player's coins in some way
func upgrade(coins: int) -> void:
	if _current_upgrade >= _max_upgrades or _upgrade_cost > coins:
		return

	_value += _value_increase
	_current_upgrade += 1
	_upgrade_cost += _cost_increase


func name() -> StringName:
	return _name


func value() -> Variant:
	return _value


func upgrade_cost() -> int:
	return _upgrade_cost
