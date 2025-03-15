extends Label

func _physics_process(delta: float) -> void:
	text = "Save ID: " + SaveManager.save_file.save_id
	text += "\nUser Name: " + SaveManager.save_file.user_name
	text += "\nCreated At: " + str(SaveManager.save_file.created_at)
	text += "\nLast Saved At: " + str(SaveManager.save_file.last_saved_at)
	text += "\nMoney: " + str(SaveManager.save_file.money)
	for creature_data in SaveManager.save_file.creature_inventory:
		text += "\nCreature: " + creature_data.creature_name
