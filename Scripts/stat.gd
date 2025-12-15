class_name Stat extends Resource

@export var _name: StringName
@export var _value: Variant

@export var _max_upgrades: int
@export var _current_upgrade := 0
## function used to upgrade [member Stat._value]: func(value: Variant) -> Variant
@export var _upgrade_f: Callable

@export var _upgrade_cost: int
## function used to increase [member Stat._upgrade_cost]: func(value: Variant) -> Variant
@export var _cost_increase_f: Callable


func _init(
	name_: StringName,
	value_: Variant,
	max_upgrades,
	upgrade_f: Callable,
	upgrade_cost_: int,
	cost_increase_f: Callable
) -> void:
	_name = name_
	_value = value_
	_max_upgrades = max_upgrades
	_upgrade_f = upgrade_f
	_upgrade_cost = upgrade_cost_
	_cost_increase_f = cost_increase_f


# TODO: get the player's coins in some way
func upgrade(coins: int) -> void:
	if _current_upgrade >= _max_upgrades or _upgrade_cost > coins:
		return

	_value = _upgrade_f.call(_value)
	_current_upgrade += 1
	_upgrade_cost = _cost_increase_f.call(_upgrade_cost)


func name() -> StringName:
	return _name


func value() -> Variant:
	return _value


func upgrade_cost() -> int:
	return _upgrade_cost
