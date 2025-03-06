## Base class for all creature components.
## 
## CreatureComponent provides a foundation for building modular creature behaviors and attributes.
## It handles common tasks like stat modification, property management, and signal handling,
## allowing derived components to focus on their specific functionality.
extends Node
class_name CreatureComponent

## The creature that the component belongs to.
@export var creature: Creature

## Signal emitted when any component property changes
## @param property_name: The name of the property that changed
## @param value: The new value of the property
signal property_changed(property_name, value)

## Dictionary to track modifiers applied by this component
## Format: { modifier_name: { stat_system: Object, value: float, type: int } }
var _applied_modifiers = {}

## Adds a modifier to any stat system that supports the modifier pattern
##
## Use this method to register a modifier with any compatible stat system.
## The stat system must implement at least the add_modifier() method.
##
## @param stat_system: The stat system to modify (must implement add_modifier)
## @param modifier_name: A unique name for this modifier
## @param value: Initial value for the modifier
## @param modifier_type: Optional modifier type (e.g. MULTIPLY, ADD) as defined by the stat system
func add_stat_modifier(stat_system, modifier_name: String, value: float, modifier_type = null) -> void:
	if not stat_system or not stat_system.has_method("add_modifier"):
		push_error("Invalid stat system provided to add_stat_modifier")
		return
		
	_applied_modifiers[modifier_name] = {
		"stat_system": stat_system,
		"value": value,
		"type": modifier_type
	}
	
	if modifier_type != null:
		stat_system.add_modifier(modifier_name, value, modifier_type)
	else:
		stat_system.add_modifier(modifier_name, value)
		
	if stat_system.has_method("set_modifier_enabled"):
		stat_system.set_modifier_enabled(modifier_name, true)

## Updates the value of a previously added stat modifier
##
## @param modifier_name: The name of the modifier to update (must have been added first)
## @param value: The new value for the modifier
func update_stat_modifier(modifier_name: String, value: float) -> void:
	if modifier_name in _applied_modifiers:
		var stat_system = _applied_modifiers[modifier_name]["stat_system"]
		_applied_modifiers[modifier_name]["value"] = value
		
		if stat_system and stat_system.has_method("set_modifier"):
			stat_system.set_modifier(modifier_name, value)

## Helper to clamp a value between a minimum and maximum
##
## Useful for properties that need to stay within a specific range.
##
## @param value: The value to clamp
## @param min_value: The minimum allowed value (default: 0.0)
## @param max_value: The maximum allowed value (default: 1.0)
## @return: The clamped value
func clamp_value(value: float, min_value: float = 0.0, max_value: float = 1.0) -> float:
	return clamp(value, min_value, max_value)

## Virtual method for component initialization
##
## Override this in derived classes instead of _ready() for component setup.
## This is called automatically by _ready().
func initialize() -> void:
	pass
	
## Called when the node enters the scene tree
func _ready() -> void:
	initialize()
