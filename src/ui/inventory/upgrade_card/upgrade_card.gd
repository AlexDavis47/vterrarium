extends TextureRect
class_name UpgradeCard

# For now we're just hardcoding the single upgrade for the demo.
#@export var upgrade_data: UpgradeData

@export var name_label: Label
@export var description_label: Label
@export var icon: TextureRect
@export var cost_label: Label
@export var buy_button: TextureButton

var cost: int = 1000

func _ready():
	_update_cost()
	buy_button.pressed.connect(_on_buy_button_pressed)


func _update_cost():
	cost = int(300 * pow(1.2, SaveManager.save_file.tank_capacity_upgrades))
	cost_label.text = str(cost)

func _on_buy_button_pressed():
	if SaveManager.save_file.money < cost:
		AudioManager.play_sfx(AudioManager.SFX.CANCEL_1)
		VTGlobal.display_notification("Not enough money!")
		return

	AudioManager.play_sfx(AudioManager.SFX.POP_1)
	VTGlobal.display_notification("Upgraded tank capacity!")
	SaveManager.save_file.money -= cost
	SaveManager.save_file.tank_capacity_upgrades += 1

	_update_cost()
	VTGlobal.trigger_inventory_refresh.emit()
