extends UpgradeData
class_name UpgradeTankCapacity

func _init() -> void:
    upgrade_name = "Tank Capacity"
    upgrade_description = "Increases the maximum number of creatures your tank can hold."
    upgrade_base_cost = 50
    upgrade_cost_scaler = 1.5

func _apply_upgrade_effects() -> void:
    # Check if SaveManager and save_file exist
    if not SaveManager or not SaveManager.save_file:
        push_error("Cannot apply tank capacity upgrade: SaveManager or save_file not available.")
        return
    
    # Get the tank capacity property from the save file
    var tank_capacity_prop = SaveManager.save_file.tank_capacity
    
    # Check if the property is valid
    if not tank_capacity_prop:
        push_error("Cannot apply tank capacity upgrade: tank_capacity property not found on save_file.")
        return
        
    # Calculate the value to add (just the current level)
    var value_to_add = float(upgrade_level) # Ensure float for the helper
    
    # Update or add the modifier using the base class helper
    if not _update_or_add_modifier(tank_capacity_prop, value_to_add, IntWithModifiers.MODIFIER_ADD):
        push_error("Failed to update or add tank capacity modifier for %s" % upgrade_name)

func _remove_upgrade_effects() -> void:
    # Check if SaveManager and save_file exist
    if not SaveManager or not SaveManager.save_file:
        # Don't error on removal if save file isn't loaded, just return
        return
        
    var tank_capacity_prop = SaveManager.save_file.tank_capacity
    if not tank_capacity_prop:
        return # Property doesn't exist, nothing to remove
        
    # Use the base class helper to remove the modifier
    remove_modifier_from_property(tank_capacity_prop)
