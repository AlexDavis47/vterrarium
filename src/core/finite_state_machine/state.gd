extends Node
class_name State

@warning_ignore("unused_signal")
signal state_transition(source_state: State, new_state_name: String)

func enter():
	pass

func exit():
	pass

func update(delta : float):
	pass
