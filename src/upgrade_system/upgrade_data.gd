## Data representing an upgrade that will be applied to the user's save.
## Held in the save data, and will apply upgrade effects to the player.
extends ItemDataResource
class_name UpgradeData

## The name of the upgrade
@export var upgrade_name: String = "Upgrade"
## The description of the upgrade
@export var upgrade_description: String = "No description"
## The icon of the upgrade
@export var upgrade_icon: Texture2D
## The base cost of the upgrade
@export var upgrade_base_cost: int = 500
## The cost scaler of the upgrade. Cost is applied as (base_cost * upgrade_cost_scaler^level)
@export var upgrade_cost_scaler: float = 1.35
## The level of the upgrade
@export var upgrade_level: int = 0:
	set(value):
		var old_level = upgrade_level
		# No change, return early
		if old_level == value:
			return
			
		upgrade_level = value
		
		# Decide whether to apply or remove effects based on level change
		if old_level <= 0 and value > 0: # Just became active
			apply_upgrade()
		elif old_level > 0 and value <= 0: # Just became inactive
			remove_upgrade()
		elif old_level > 0 and value > 0: # Level changed while active
			# Re-apply to update modifier values
			_apply_upgrade_effects()
		# Else: stayed inactive (old_level <= 0 and value <= 0), do nothing


## Public functions to apply and remove upgrade effects
## Applies the upgrade to the player
func apply_upgrade() -> void:
	if upgrade_level <= 0:
		push_warning("Tried to apply upgrade %s with level %d <= 0" % [upgrade_name, upgrade_level])
		return
		
	_apply_upgrade_effects()

## Removes the upgrade from the player
func remove_upgrade() -> void:
	_remove_upgrade_effects()

## Applies the upgrade to the player
func _apply_upgrade_effects() -> void:
	push_error("Upgrade ", upgrade_name, " has no effects to apply, make sure to override _apply_upgrade_effects()")
	pass

## Removes the upgrade from the player
func _remove_upgrade_effects() -> void:
	push_error("Upgrade ", upgrade_name, " has no effects to remove, make sure to override _remove_upgrade_effects()")
	pass

### Helper functions for modifier management ###

## Updates an existing modifier or adds a new one to a property.
## Returns true if successful.
func _update_or_add_modifier(property: Resource, value: float, operation: int = 0) -> bool:
	if not _is_modifiable_property(property):
		push_error("Cannot add/update modifier for property: not a modifiable type (%s)" % property)
		return false
		
	var modifier_name = _get_modifier_name()
	
	if property.has_modifier(modifier_name):
		# Modifier exists, update its value and ensure it's enabled
		property.set_modifier(modifier_name, value)
		# Setting operation/priority might be needed if they can change, but unlikely for level-ups
		# property.set_modifier_operation(modifier_name, operation) 
		if not property.get_modifier(modifier_name).enabled:
			property.modifier_on(modifier_name)
	else:
		# Modifier doesn't exist, add and enable it
		property.add_modifier(modifier_name, value, operation) # Assume default priority 0
		property.modifier_on(modifier_name)
		
	return true

## Removes a modifier from an IntWithModifiers or FloatWithModifiers property
## Returns true if successful
func remove_modifier_from_property(property: Resource) -> bool:
	if not _is_modifiable_property(property):
		# Don't error if trying to remove from non-modifiable, might be intentional
		# push_error("Cannot remove modifier from property: not a modifiable type") 
		return false
		
	var modifier_name = _get_modifier_name()
	
	if property.has_modifier(modifier_name):
		# Ensure it's off before removing, though remove_modifier should handle this state.
		if property.get_modifier(modifier_name).enabled:
			property.modifier_off(modifier_name)
		property.remove_modifier(modifier_name)
		return true
	
	# Modifier didn't exist, return false but don't error
	return false

## Returns true if the property is an IntWithModifiers or FloatWithModifiers
func _is_modifiable_property(property: Resource) -> bool:
	return property is IntWithModifiers or property is FloatWithModifiers

## Generates a consistent modifier name for this upgrade based on its resource path
func _get_modifier_name() -> String:
	# Using resource path ensures uniqueness if names clash but they are different resources
	if resource_path.is_empty():
		push_warning("Upgrade resource path is empty for '%s'. Using name as modifier ID, might cause conflicts." % upgrade_name)
		return upgrade_name # Fallback to name if path is not available (e.g., in-memory instances)
	return resource_path # Use the unique resource path


## Levels up the upgrade
func level_up() -> void:
	upgrade_level += 1

## Returns the name of the upgrade
func get_upgrade_name() -> String:
	return upgrade_name

## Returns the description of the upgrade
func get_upgrade_description() -> String:
	return upgrade_description

## Returns the icon of the upgrade
func get_upgrade_icon() -> Texture2D:
	return upgrade_icon

## Returns the cost of the upgrade
func get_upgrade_cost() -> int:
	return int(upgrade_base_cost * pow(upgrade_cost_scaler, upgrade_level))

## Returns the level of the upgrade
func get_upgrade_level() -> int:
	return upgrade_level

## Returns the cost scaler of the upgrade
func get_upgrade_cost_scaler() -> float:
	return upgrade_cost_scaler

## Returns the base cost of the upgrade
func get_upgrade_base_cost() -> int:
	return upgrade_base_cost
