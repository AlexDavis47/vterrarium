extends State
class_name FiniteStateMachine

var states : Dictionary = {}
var current_state : State
@export var initial_state : State
@export_category("Debug")
@export var print_state_changes : bool = false
@export var print_updated_state : bool = false

# This is the main Finite State Machine class which manages all of the state transitions
# Notably, this class also functions as a State itself, allowing for nested state machines
# This is particularly useful for managing state machine sub-sets, such as player states
func _ready():
	for child in get_children():
		if child is State and child.get_parent() == self:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)

	# Only initialize immediately if this is the root machine
	if is_root_machine() and initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if is_root_machine():
		update(delta) # We are the highest level FSM, so we need to update ourselves

# Override State methods
# In the case of the FSM being a state itself, these will need to be implemented
# But by default, they will simply
func enter():
	# If we want to allow FSMs to retain their own state when exited until re-entered,
	# we may want to add a check here.
	# Right now, every time we enter the FSM, we will reset to the initial state
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func exit():
	# I don't think there's anything to go wrong here, but we should consider it could in the future.
	if current_state:
		current_state.exit()
		current_state = null
		
func update(delta: float):
	# If this FSM is getting updated, aka, it is a state itself, this will update the current state
	if current_state:
		current_state.update(delta)
		if print_updated_state:
			print("Updated state: " + current_state.name)

func change_state(source_state : State, new_state_name : String) -> void:
	if source_state != current_state:
		print("Invalid change_state trying from: " + source_state.name + " but currently in: " + current_state.name)
		return

	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("FSM " + name + ": New state is empty")
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	new_state.enter()

	if print_state_changes:
		print("FSM " + name + " Changed state from: " + source_state.name + " to: " + new_state.name)

func force_state(new_state_name : String) -> void:
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("FSM " + name + ": New state is empty")
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	new_state.enter()

	if print_state_changes:
		print("FSM " + name + " Forced state to: " + new_state.name)

# Helper Functions
func is_root_machine() -> bool:
	return !(get_parent() is FiniteStateMachine)
