extends Node

const SAVE_FILE_DIR: String = "res://save_files"
const SAVE_FILE_EXTENSION: String = ".tres"
const BACKUP_EXTENSION: String = ".old"

## The current save file
@export var save_file: SaveFile
## Signal emitted when a save file is loaded
signal save_loaded
## Signal emitted when a save file is saved
signal save_saved
## Signal emitted when a new save file is created
signal save_created
## Signal emitted when a backup save file is loaded
signal backup_loaded

func _ready() -> void:
	# Ensure the save directory exists
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(SAVE_FILE_DIR):
		dir.make_dir(SAVE_FILE_DIR)
	
	var save_files = get_all_save_files()
	if save_files.is_empty():
		create_save_file()
		# For testing
		CreatureFactory.run_test_cycle()
		save_game()
	else:
		load_game(save_files[0].save_id)

	handle_auto_save()


func handle_auto_save() -> void:
	await get_tree().create_timer(1.0).timeout
	save_game()
	handle_auto_save()

## Creates a new save file with default values
func create_save_file() -> void:
	save_file = SaveFile.new()
	save_file.save_id = Utils.generate_unique_id()
	save_file.user_name = "Unnamed User"
	save_file.money = 0
	save_file.creature_inventory = []
	save_file.created_at = Time.get_datetime_dict_from_system()
	save_file.last_saved_at = save_file.created_at
	
	emit_signal("save_created")

## Saves the current save file to disk
func save_game() -> void:
	if not save_file:
		push_error("Attempted to save game with no active save file")
		return
		
	save_file.last_saved_at = Time.get_datetime_dict_from_system()
	var save_file_path: String = get_save_file_path(save_file.save_id)
	
	# Create backup of existing save file if it exists
	if FileAccess.file_exists(save_file_path):
		var backup_path = save_file_path + BACKUP_EXTENSION
		var error = DirAccess.copy_absolute(save_file_path, backup_path)
		if error != OK:
			push_warning("Failed to create backup save file: " + str(error))
	
	var error = ResourceSaver.save(save_file, save_file_path)
	if error != OK:
		push_error("Failed to save game: " + str(error))
		return
		
	emit_signal("save_saved")

## Loads a save file by ID
func load_game(save_id: String = "") -> bool:
	var path: String
	
	if save_id.is_empty():
		# Try to load the most recent save file
		var save_files = get_all_save_files()
		if save_files.is_empty():
			push_error("No save files found")
			return false
			
		# Sort by last saved time (most recent first)
		save_files.sort_custom(func(a, b): return a.last_saved_at > b.last_saved_at)
		path = get_save_file_path(save_files[0].save_id)
	else:
		path = get_save_file_path(save_id)
	
	if not FileAccess.file_exists(path):
		push_error("Save file does not exist: " + path)
		return false
		
	var loaded_save = ResourceLoader.load(path)
	if not loaded_save:
		push_error("Failed to load save file: " + path)
		
		# Try to load from backup
		var backup_path = path + BACKUP_EXTENSION
		if FileAccess.file_exists(backup_path):
			print("Attempting to load from backup file: " + backup_path)
			loaded_save = ResourceLoader.load(backup_path)
			if loaded_save:
				save_file = loaded_save
				_respawn_creatures()
				emit_signal("backup_loaded")
				# Restore the backup as the main save
				save_game()
				return true
		
		return false
		
	save_file = loaded_save
	_respawn_creatures()
	emit_signal("save_loaded")
	return true


func _respawn_creatures() -> void:
	print("Respawning creatures")
	for creature in save_file.creature_inventory:
		if creature.creature_is_in_tank:
			CreatureFactory.spawn_creature(creature)

## Returns the full path for a save file with the given ID
func get_save_file_path(save_id: String) -> String:
	return SAVE_FILE_DIR + "/" + save_id + SAVE_FILE_EXTENSION

## Returns an array of all save files
func get_all_save_files() -> Array[SaveFile]:
	var save_files: Array[SaveFile] = []
	var dir = DirAccess.open(SAVE_FILE_DIR)
	
	if not dir:
		push_error("Failed to open save directory")
		return save_files
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(SAVE_FILE_EXTENSION) and not file_name.ends_with(BACKUP_EXTENSION):
			var path = SAVE_FILE_DIR + "/" + file_name
			var save = ResourceLoader.load(path)
			if save is SaveFile:
				save_files.append(save)
		file_name = dir.get_next()
		
	return save_files

## Deletes a save file
func delete_save_file(save_file: SaveFile) -> bool:
	var path = get_save_file_path(save_file.save_id)
	var backup_path = path + BACKUP_EXTENSION
	
	if not FileAccess.file_exists(path):
		push_error("Cannot delete non-existent save file: " + path)
		return false
		
	var dir = DirAccess.open(SAVE_FILE_DIR)
	if not dir:
		push_error("Failed to open save directory")
		return false
		
	var error = dir.remove(save_file.save_id + SAVE_FILE_EXTENSION)
	
	# Also remove backup if it exists
	if FileAccess.file_exists(backup_path):
		dir.remove(save_file.save_id + SAVE_FILE_EXTENSION + BACKUP_EXTENSION)
		
	return error == OK
