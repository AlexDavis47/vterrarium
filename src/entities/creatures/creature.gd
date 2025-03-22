## This creature class represents the instanced version of a creature data resource
## The creature data resource itself is the "real" creature, and this class is just the thing that shows up in the tank.
extends CharacterBody3D
class_name Creature

signal started_starving
signal stopped_starving

var is_starving: bool = false

var hunger_bracket: CreatureData.HungerBracket = CreatureData.HungerBracket.Full
var happiness_bracket: CreatureData.HappinessBracket = CreatureData.HappinessBracket.Happy

@export var creature_mesh: MeshInstance3D
var creature_data: CreatureData

var debug_label: Label3D

func _ready():
	creature_mesh.mesh = load(creature_data.creature_mesh_uuid).duplicate(true)
	var mesh: Mesh = creature_mesh.mesh
	mesh.surface_set_material(0, mesh.surface_get_material(0).duplicate(true))
	print("creature material: ", mesh.surface_get_material(0))
	_apply_tint()
	add_to_group("creatures")
	collision_layer = 0
	set_collision_layer_value(2, true)
	global_position = creature_data.creature_position
	scale = Vector3(creature_data.creature_size, creature_data.creature_size, creature_data.creature_size)

	debug_label = Label3D.new()
	debug_label.no_depth_test = true
	debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	#add_child(debug_label)


func _apply_tint() -> void:
	# Get the material of the creature mesh
	var material: StandardMaterial3D = creature_mesh.mesh.surface_get_material(0) as StandardMaterial3D
	# Mix the default color of the material with the tint color
	# Remove alpha from the tint color
	var tint_color: Color = creature_data.creature_tint
	tint_color.a = 1.0
	# Mix the default color of the material with the tint color
	var mixed_color: Color = material.albedo_color.lerp(tint_color, creature_data.creature_tint_amount)
	# Apply the mixed color to the material
	material.albedo_color = mixed_color


func _physics_process(delta: float) -> void:
	_process_hunger(delta)
	_process_happiness(delta)
	_process_light(delta)
	_process_temperature(delta)
	_process_position_data(delta)
	_process_money(delta)

	hunger_bracket = get_hunger_bracket()
	happiness_bracket = get_happiness_bracket()

	debug_label.text = str(creature_data.creature_name, "\n",
		"Satiation: ", creature_data.creature_satiation, "\n",
		"Light: ", creature_data.creature_light_contentment, "\n",
		"Temperature: ", creature_data.creature_temperature_contentment, "\n",
		"Happiness: ", creature_data.creature_happiness, "\n",
		"Money: ", creature_data.creature_money_per_hour, "\n",
		"Hunger Bracket: ", hunger_bracket, "\n",
		"Happiness Bracket: ", happiness_bracket)
		

## Process the hunger of the creature every physics frame
func _process_hunger(delta: float) -> void:
	creature_data.creature_satiation -= creature_data.creature_hunger_rate * (delta / 3600.0)
	if creature_data.creature_satiation <= 0.0:
		if not is_starving:
			is_starving = true
			started_starving.emit()
	else:
		if is_starving:
			is_starving = false
			stopped_starving.emit()

## First calculates the light level preference against the light level of the tank
## Then interpolates the light level contentment to that calculated value
func _process_light(delta: float) -> void:
	# Get the light level from the tank
	var light_level = VTHardware.brightness
	# Use the light level preference curve to calculate the light level contentment
	var sampled_light_level = creature_data.creature_light_preference.sample(light_level)
	# Interpolate the light level contentment to that calculated value
	creature_data.creature_light_contentment = lerp(creature_data.creature_light_contentment, sampled_light_level, delta * 30)

## First calculates the temperature level preference against the temperature level of the tank
## Then interpolates the temperature level contentment to that calculated value
func _process_temperature(delta: float) -> void:
	# Get the temperature level from the tank
	var temperature_level = VTHardware.temperature
	# Use the temperature level preference curve to calculate the temperature level contentment
	var sampled_temperature_level = creature_data.creature_temperature_preference.sample(temperature_level)
	# Interpolate the temperature level contentment to that calculated value
	creature_data.creature_temperature_contentment = lerp(creature_data.creature_temperature_contentment, sampled_temperature_level, delta * 30)

## Process the happiness of the creature based on hunger
func _process_happiness(delta: float) -> void:
	var target_happiness: float = 1.0
	# Reduce happiness based on hunger (lower satiation = lower happiness)
	target_happiness -= (1.0 - creature_data.creature_satiation)
	# Reduce happiness based on light level (lower light contentment = lower happiness)
	target_happiness -= (1.0 - creature_data.creature_light_contentment)
	# Reduce happiness based on temperature level (lower temperature contentment = lower happiness)
	target_happiness -= (1.0 - creature_data.creature_temperature_contentment)
	# Clamp happiness to 0 and 1
	target_happiness = clamp(target_happiness, 0.0, 1.0)
	# Interpolate happiness to the target happiness
	creature_data.creature_happiness = lerp(creature_data.creature_happiness, target_happiness, delta * 5)

func _process_position_data(delta: float) -> void:
	creature_data.creature_position = global_position

func _process_money(delta: float) -> void:
	# Money rate is multiplied by happiness
	SaveManager.save_file.money += creature_data.creature_money_per_hour * creature_data.creature_happiness * delta / 3600.0


func get_hunger_bracket() -> CreatureData.HungerBracket:
	if creature_data.creature_satiation <= 0.25:
		return CreatureData.HungerBracket.Starving
	elif creature_data.creature_satiation <= 0.75:
		return CreatureData.HungerBracket.Hungry
	else:
		return CreatureData.HungerBracket.Full

func get_happiness_bracket() -> CreatureData.HappinessBracket:
	if creature_data.creature_happiness <= 0.25:
		return CreatureData.HappinessBracket.Depressed
	elif creature_data.creature_happiness <= 0.5:
		return CreatureData.HappinessBracket.Sad
	elif creature_data.creature_happiness <= 0.75:
		return CreatureData.HappinessBracket.Happy
	else:
		return CreatureData.HappinessBracket.Ecstatic


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
