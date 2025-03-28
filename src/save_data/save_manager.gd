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

# Threading variables
var save_mutex = Mutex.new()
var save_thread = null
var is_saving = false

var auto_save_timer: Timer = null

func _ready() -> void:
	# Ensure the save directory exists
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(SAVE_FILE_DIR):
		dir.make_dir(SAVE_FILE_DIR)
	
	print("Checking for save files...")
	var save_files = get_all_save_files()
	print("Found " + str(save_files.size()) + " valid save files")
	
	# List all files in save directory for debugging
	var save_dir = DirAccess.open(SAVE_FILE_DIR)
	if save_dir:
		print("== FILES IN SAVE DIRECTORY ==")
		save_dir.list_dir_begin()
		var file_name = save_dir.get_next()
		while file_name != "":
			if not save_dir.current_is_dir():
				print("- " + file_name)
			file_name = save_dir.get_next()
		print("===========================")
	
	# Look for standalone .old files that might not have been processed
	var found_backup = false
	if save_files.is_empty():
		print("No valid save files found, checking for standalone .old files")
		save_dir = DirAccess.open(SAVE_FILE_DIR)
		if save_dir:
			save_dir.list_dir_begin()
			var file_name = save_dir.get_next()
			while file_name != "" and not found_backup:
				if not save_dir.current_is_dir() and file_name.ends_with(BACKUP_EXTENSION):
					print("Found standalone backup file: " + file_name)
					var backup_path = SAVE_FILE_DIR + "/" + file_name
					var main_path = backup_path.substr(0, backup_path.length() - BACKUP_EXTENSION.length())
					print("Manually restoring to: " + main_path)
					
					# Try direct file copy
					var file_content = FileAccess.open(backup_path, FileAccess.READ)
					if file_content:
						var backup_data = file_content.get_as_text()
						file_content.close()
						
						var main_file = FileAccess.open(main_path, FileAccess.WRITE)
						if main_file:
							main_file.store_string(backup_data)
							main_file.close()
							print("Manually restored backup file content")
							
							# Try to load the restored file
							var restored_save = ResourceLoader.load(main_path)
							if restored_save is SaveFile:
								print("Successfully loaded manually restored save")
								save_files.append(restored_save)
								found_backup = true
							else:
								print("Failed to load manually restored save")
					
				file_name = save_dir.get_next()
	
	if save_files.is_empty():
		print("No save files found or recovered, creating new save file")
		create_save_file()
		# For testing
		CreatureFactory.run_test_cycle()
		AccessoryFactory.create_test_top_hat()
		AccessoryFactory.create_test_party_hat()
		save_game() # Use save_game instead of _thread_save_game
	else:
		print("Loading save file: " + save_files[0].save_id)
		load_game(save_files[0].save_id)

	setup_auto_save()

func setup_auto_save() -> void:
	print("Setting up auto-save timer...")
	auto_save_timer = Timer.new()
	auto_save_timer.name = "AutoSaveTimer" # Give it a name to help with debugging
	add_child(auto_save_timer)
	auto_save_timer.wait_time = 1.0
	auto_save_timer.one_shot = false # Make sure it repeats
	auto_save_timer.timeout.connect(_on_auto_save_timer_timeout)
	auto_save_timer.start()
	print("Auto-save timer started with interval: 1.0 seconds")

func _on_auto_save_timer_timeout() -> void:
	if not is_saving and (save_thread == null or not save_thread.is_alive()):
		save_game()


## Public method to initiate a save
func save_game() -> void:
	# Check if we're already saving
	if is_saving:
		return
		
	# Clean up previous thread if it exists but is no longer alive
	if save_thread != null:
		if not save_thread.is_alive():
			# Thread is done, we can safely wait_to_finish() to clean it up
			# without blocking since it's already done
			save_thread.wait_to_finish()
			save_thread = null
		else:
			# Thread is still running, we should not start another one
			return
			
	# Start new thread
	is_saving = true
	save_thread = Thread.new()
	save_thread.start(Callable(self, "_thread_save_game"))

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

## Threaded function that handles the actual saving
func _thread_save_game() -> void:
	# Lock access to shared resources during save
	save_mutex.lock()
	
	# Update save timestamp
	if save_file:
		save_file.last_saved_at = Time.get_datetime_dict_from_system()
		var save_file_path: String = get_save_file_path(save_file.save_id)
		
		# Create backup of existing save file if it exists
		if FileAccess.file_exists(save_file_path):
			var backup_path = save_file_path + BACKUP_EXTENSION
			var error = DirAccess.copy_absolute(save_file_path, backup_path)
			if error != OK:
				push_warning("Failed to create backup save file: " + str(error))
		
		# Save the file
		var error = ResourceSaver.save(save_file, save_file_path)
		if error != OK:
			push_error("Failed to save game: " + str(error))
	
	# Use a callable to emit the signal on the main thread
	call_deferred("_emit_save_completed")
	save_mutex.unlock()
	is_saving = false

func _emit_save_completed() -> void:
	emit_signal("save_saved")

# Make sure to clean up threads when closing
func _exit_tree() -> void:
	if save_thread != null and save_thread.is_alive():
		save_thread.wait_to_finish()

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
				save_game() # Use save_game instead of _thread_save_game
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
	var main_save_paths = []
	var backup_save_paths = []
	
	# First, collect all save and backup file paths
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(SAVE_FILE_EXTENSION) and not file_name.ends_with(BACKUP_EXTENSION):
				main_save_paths.append(SAVE_FILE_DIR + "/" + file_name)
			elif file_name.ends_with(SAVE_FILE_EXTENSION + BACKUP_EXTENSION):
				backup_save_paths.append(SAVE_FILE_DIR + "/" + file_name)
		file_name = dir.get_next()
	
	# Try to load from main save files first
	for main_path in main_save_paths:
		var validated_save = validate_save_file(main_path)
		if validated_save:
			save_files.append(validated_save)
	
	# If no valid saves found, try standalone backups
	if save_files.is_empty() and not backup_save_paths.is_empty():
		print("No valid main save files found, checking standalone backups...")
		for backup_path in backup_save_paths:
			var main_path = backup_path.substr(0, backup_path.length() - BACKUP_EXTENSION.length())
			print("Trying to restore from standalone backup: " + backup_path)
			
			# Try to load backup directly
			var backup_save = ResourceLoader.load(backup_path)
			if backup_save is SaveFile:
				# Copy backup to main file location
				var error = DirAccess.copy_absolute(backup_path, main_path)
				if error == OK:
					print("Successfully restored save from backup: " + main_path)
					save_files.append(backup_save)
				else:
					push_warning("Failed to restore backup file: " + str(error))
	
	return save_files

## Validates and attempts to recover a save file if corrupted
## Returns the valid SaveFile or null if unrecoverable
func validate_save_file(file_path: String) -> SaveFile:
	print("Validating save file: " + file_path)
	
	# Check if the main file exists
	if not FileAccess.file_exists(file_path):
		push_warning("Save file doesn't exist: " + file_path)
		return null
		
	# Try to load the main save file
	var save = ResourceLoader.load(file_path)
	if save is SaveFile:
		print("Valid save file found: " + file_path)
		return save
		
	print("Save file exists but couldn't be loaded: " + file_path)
	
	# Main file exists but couldn't be loaded, try the backup
	var backup_path = file_path + BACKUP_EXTENSION
	if not FileAccess.file_exists(backup_path):
		push_warning("No backup file found for corrupted save: " + backup_path)
		return null
		
	print("Found backup file, attempting recovery: " + backup_path)
	
	# Try to load the backup
	var backup_save = ResourceLoader.load(backup_path)
	if not (backup_save is SaveFile):
		push_warning("Both save and backup files are corrupted: " + file_path)
		return null
		
	print("Valid backup found, restoring to main file")
	
	# Backup is valid, copy it to the main file
	var file_content = FileAccess.open(backup_path, FileAccess.READ)
	if not file_content:
		push_warning("Failed to open backup file for reading")
		return null
		
	var backup_data = file_content.get_as_text()
	file_content.close()
	
	var main_file = FileAccess.open(file_path, FileAccess.WRITE)
	if not main_file:
		push_warning("Failed to open main file for writing")
		return null
		
	main_file.store_string(backup_data)
	main_file.close()
	
	print("Successfully restored save file from backup")
	
	# Now try to load the restored file
	var restored_save = ResourceLoader.load(file_path)
	if restored_save is SaveFile:
		print("Restored save file loaded successfully")
		return restored_save
	else:
		push_warning("Failed to load restored save file")
		return null

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
