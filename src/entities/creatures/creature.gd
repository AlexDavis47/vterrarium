## This creature class represents the instanced version of a creature data resource.
## The creature data resource itself is the "real" creature, and this class is just 
## the thing that shows up in the tank.
extends CharacterBody3D
class_name Creature

# Signals
signal started_starving
signal stopped_starving

# Enums and Constants
const HAPPINESS_LERP_SPEED: float = 0.1
const CONTENTMENT_LERP_SPEED: float = 0.2

# Exported variables
@export_group("Components")
@export var creature_mesh: MeshInstance3D
@export var _accessory_hat_attachment: Node3D

@export_group("Debug")
## For when we want to preview a creature without it being in the tank
@export var _is_in_preview_mode: bool = false

# Public variables
var creature_data: CreatureData

# Private variables
var _debug_label: Label3D
var _is_starving: bool = false

var _process_scheduler: ProcessScheduler = ProcessScheduler.new()

# Built-in functions
func _ready() -> void:
	_initialize_creature()
	_setup_mesh()
	_setup_physics()
	_setup_debug()
	_connect_signals()

func _physics_process(delta: float) -> void:
	if _is_in_preview_mode:
		return
	
	_process_position_data(delta)

# Signal connections
func _connect_signals() -> void:
	if _is_in_preview_mode:
		return
	add_child(_process_scheduler)
		
	_process_scheduler.tick_second.connect(_on_tick_second)


# Scheduler callbacks
func _on_tick_second(delta: float) -> void:
	_process_happiness(delta)
	_process_light(delta)
	_process_temperature(delta)
	_update_starving_state()
	_process_hunger(delta)
	_process_money(delta)
	_process_age(delta)
	_update_brackets()

# Initialization methods
func _initialize_creature() -> void:
	if _is_in_preview_mode:
		process_mode = PROCESS_MODE_DISABLED
		return
		
	add_to_group("creatures")
	global_position = creature_data.creature_position
	scale = Vector3(creature_data.creature_size, creature_data.creature_size, creature_data.creature_size)

func _setup_mesh() -> void:
	creature_mesh.mesh = creature_mesh.mesh.duplicate(true)
	var mesh: Mesh = creature_mesh.mesh
	mesh.surface_set_material(0, mesh.surface_get_material(0).duplicate(true))
	
	_apply_tint()
	_apply_accesories()

func _setup_physics() -> void:
	if _is_in_preview_mode:
		return
		
	collision_layer = 0
	set_collision_layer_value(2, true)

func _setup_debug() -> void:
	if _is_in_preview_mode:
		return
		
	_debug_label = Label3D.new()
	_debug_label.no_depth_test = true
	_debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED

# State processing methods
func _process_happiness(delta: float) -> void:
	var target_happiness: float = _calculate_target_happiness()
	var lerp_factor: float = delta * HAPPINESS_LERP_SPEED
	
	creature_data.creature_happiness = lerp(
		creature_data.creature_happiness,
		target_happiness,
		lerp_factor
	)

func _calculate_target_happiness() -> float:
	var happiness: float = 1.0
	
	if creature_data.creature_hunger_bracket != CreatureData.HungerBracket.Full:
		happiness -= (1.0 - creature_data.creature_satiation)
	
	happiness -= (2.0 - creature_data.creature_light_contentment - creature_data.creature_temperature_contentment)
	
	return clamp(happiness, 0.0, 1.0)

func _process_light(delta: float) -> void:
	var light_level: float = VTHardware.brightness
	var target_contentment: float = creature_data.creature_light_preference.sample(light_level)
	
	creature_data.creature_light_contentment = lerp(
		creature_data.creature_light_contentment,
		target_contentment,
		delta * CONTENTMENT_LERP_SPEED
	)

func _process_temperature(delta: float) -> void:
	var temperature_level: float = VTHardware.temperature
	var target_contentment: float = creature_data.creature_temperature_preference.sample(temperature_level)
	
	creature_data.creature_temperature_contentment = lerp(
		creature_data.creature_temperature_contentment,
		target_contentment,
		delta * CONTENTMENT_LERP_SPEED
	)

func _process_hunger(delta: float) -> void:
	creature_data.creature_satiation -= creature_data.creature_hunger_rate * (delta / 3600.0)

func _update_starving_state() -> void:
	var is_now_starving: bool = creature_data.creature_satiation <= 0.0
	
	if is_now_starving == _is_starving:
		return
		
	_is_starving = is_now_starving
	if _is_starving:
		started_starving.emit()
	else:
		stopped_starving.emit()

func _process_position_data(delta: float) -> void:
	creature_data.creature_position = global_position

func _process_money(delta: float) -> void:
	var hourly_money: float = creature_data.creature_money_per_hour * creature_data.creature_happiness
	SaveManager.save_file.money += hourly_money * delta / 3600.0

func _process_age(delta: float) -> void:
	creature_data.creature_age += delta / 3600.0

func _update_brackets() -> void:
	creature_data.creature_age_bracket = creature_data.get_age_bracket()
	creature_data.creature_happiness_bracket = creature_data.get_happiness_bracket()
	creature_data.creature_hunger_bracket = creature_data.get_hunger_bracket()

# Appearance methods
func _apply_tint() -> void:
	var material: StandardMaterial3D = creature_mesh.mesh.surface_get_material(0) as StandardMaterial3D
	var tint_color: Color = _get_adjusted_tint_color()
	
	material.albedo_color = material.albedo_color.lerp(
		tint_color,
		creature_data.creature_tint_amount
	)

func _get_adjusted_tint_color() -> Color:
	var tint_color: Color = creature_data.creature_tint
	tint_color.a = 1.0
	return tint_color

func _apply_accesories() -> void:
	if not _accessory_hat_attachment:
		return

	_clear_existing_accessories()
	_add_new_accessories()

func _clear_existing_accessories() -> void:
	for child in _accessory_hat_attachment.get_children():
		child.queue_free()

func _add_new_accessories() -> void:
	var accessories: Array[AccessoryData] = AccessoryFactory.get_all_accessories_by_creature_id(
		creature_data.creature_id
	)
	
	for accessory in accessories:
		if accessory.accessory_category != AccessoryFactory.AccessoryType.HAT:
			continue
			
		var hat_instance: Node3D = AccessoryFactory.instantiate_accessory(accessory)
		_accessory_hat_attachment.add_child(hat_instance)

# Public methods
func find_closest_food() -> FishFood:
	var food_items = get_tree().get_nodes_in_group("fish_food")
	var closest_distance = INF
	var closest_food: FishFood = null
	for food in food_items:
		if food is FishFood and food.is_edible:
			var distance = global_position.distance_to(food.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_food = food
	return closest_food
