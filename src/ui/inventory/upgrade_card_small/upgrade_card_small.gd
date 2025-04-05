## This is a card style item to display an upgrade in the inventory.
extends TextureRect
class_name UpgradeCardSmall

@export var upgrade_data: UpgradeData

@export var name_label: Label
@export var cost_label: Label
@export var level_label: Label
@export var purchase_button: TextureButton

var _detailed_view_ui_scene: PackedScene = preload("uid://c7ripghigdapa")

signal purchase_button_pressed(upgrade_data: UpgradeData)

func _ready() -> void:
	purchase_button.pressed.connect(_on_purchase_button_pressed)
	SaveManager.save_file.money_changed.connect(_on_money_changed)
	
	for upgrade in SaveManager.save_file.upgrade_inventory: # If this upgrade is already in the inventory, use that instance
		if upgrade.upgrade_name == upgrade_data.upgrade_name:
			upgrade_data = upgrade
			break

	update_ui()

func _on_purchase_button_pressed() -> void:
	purchase_button_pressed.emit(upgrade_data)
	AudioManager.play_sfx(AudioManager.SFX.POP_1, 0.8, 1.2)
	AudioManager.play_sfx(AudioManager.SFX.COINS_1, 0.8, 1.2)
	_handle_upgrade_purchase()

func _handle_upgrade_purchase() -> void:
	# First deduct money before modifying the upgrade
	var cost = upgrade_data.get_upgrade_cost()
	SaveManager.save_file.money -= cost
	
	# Find if the upgrade already exists in inventory
	var upgrade: UpgradeData = null
	for u in SaveManager.save_file.upgrade_inventory:
		if u.upgrade_name == upgrade_data.upgrade_name:
			# Make sure we're comparing actual resources if possible
			# This assumes upgrade_data is the template and u is the instance
			# A better comparison might involve a unique ID if names aren't guaranteed unique
			# For now, assuming name is sufficient identifier *within* the inventory
			upgrade = u
			break
			
	if upgrade == null: # If the upgrade doesn't exist, add it
		upgrade = upgrade_data.duplicate() # Duplicate the template
		upgrade.upgrade_level = 0 # Start at 0 before setting to 1 to trigger setter logic
		upgrade.upgrade_level = 1 # Set level to 1, setter will apply effects
		SaveManager.save_file.upgrade_inventory.append(upgrade)
		# No need to call _apply_upgrade_effects() here, setter handles it
	else: # If the upgrade already exists, increment the level
		upgrade.upgrade_level += 1
		# No need to call _apply_upgrade_effects() here, setter handles it
	
	# Update UI after changes
	update_ui()

func update_ui() -> void:
	_update_name()
	_update_cost()
	_update_level()
	_update_purchase_button()

func _update_name() -> void:
	name_label.text = upgrade_data.get_upgrade_name()

func _update_cost() -> void:
	cost_label.text = "Cost: " + str(upgrade_data.get_upgrade_cost())

func _update_level() -> void:
	level_label.text = "Level: " + str(upgrade_data.get_upgrade_level())

func _update_purchase_button() -> void:
	# Disable purchase button if player doesn't have enough money
	if SaveManager.save_file.money < upgrade_data.get_upgrade_cost():
		purchase_button.disabled = true
		purchase_button.modulate = Color(1, 1, 1, 0.35)
	else:
		purchase_button.disabled = false
		purchase_button.modulate = Color(1, 1, 1, 1)

func _on_money_changed() -> void:
	_update_purchase_button()
