extends Node


## Generate a unique ID
func generate_unique_id() -> String:
	return str(randi()) + str(int(Time.get_unix_time_from_system()))
