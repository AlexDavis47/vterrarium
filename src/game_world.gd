extends Node3D
class_name VTGameWorld

@export var keyboard: OnscreenKeyboard
@export var test: FloatWithModifiers = FloatWithModifiers.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	VTGlobal.game_world = self
	VTGlobal.onscreen_keyboard = keyboard


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		# Find existing tank capacity upgrade or create a new one
		var tank_upgrade: UpgradeTankCapacity
		
		for upgrade in SaveManager.save_file.upgrade_inventory:
			if upgrade is UpgradeTankCapacity:
				upgrade.upgrade_level += 1 # This will trigger auto-application via setter
				print("Tank capacity upgraded to level ", upgrade.upgrade_level)
				return
		
		# Create new tank capacity upgrade
		tank_upgrade = UpgradeTankCapacity.new()
		tank_upgrade.upgrade_level = 1 # This will trigger application via setter
		SaveManager.save_file.upgrade_inventory.append(tank_upgrade)
		print("New tank capacity upgrade created at level 1")
