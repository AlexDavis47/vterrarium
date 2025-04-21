extends Resource
class_name UpgradeData

@export var upgrade_name: String = "Upgrade Name"
@export var upgrade_description: String = "Upgrade Description"
@export var upgrade_icon: Texture2D
@export var upgrade_cost: int = 1000

## Whether the upgrade is currently active
var is_active: bool = false

## Activates the upgrade, cannot be activated if it is already active
func activate_upgrade() -> void:
	if is_active:
		return
	is_active = true

## Deactivates the upgrade, cannot be deactivated if it is not active
func deactivate_upgrade() -> void:
	if !is_active:
		return
	is_active = false

## Processes the upgrade per physics frame, cannot be processed if it is not active
func process_upgrade() -> void:
	if !is_active:
		return
