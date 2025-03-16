extends Control

@export var creature: Creature

var creature_item_scene: PackedScene = preload("uid://8agasujxbyo2")
var creature_item: UICreatureControlNode

func _physics_process(delta):
	var creature_position: Vector2 = VTGlobal.top_camera.unproject_position(creature.global_position)
	position.x = creature_position.x - size.x / 2
	position.y = creature_position.y - size.y / 2


func _ready():
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	print(event)
	if event is InputEventScreenTouch:
		if event.pressed:
			if creature_item:
				creature_item.queue_free()
				creature_item = null
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			creature_item = creature_item_scene.instantiate() as UICreatureControlNode
			creature_item.creature_data = creature.creature_data
			add_child(creature_item)
