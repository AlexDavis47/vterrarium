extends Node
class_name VTVisibilityComponent

@export var target_screen: VTConfig.Screen = VTConfig.Screen.SHARED
@export var propagate_to_children: bool = false

func _ready() -> void:
	_update_visibility()

func _update_visibility() -> void:
	var layer: int = 0
	
	# Set the appropriate bit in the layer mask
	if target_screen == VTConfig.Screen.SHARED:
		layer |= 1 << (VTConfig.get_shared_screen_layer() - 1)
	elif target_screen == VTConfig.Screen.TOP:
		layer |= 1 << (VTConfig.get_top_screen_layer() - 1)
	else:
		layer |= 1 << (VTConfig.get_front_screen_layer() - 1)

	# Set parent visibility
	var parent: Node = get_parent()
	if parent.has_method("set_layer_mask"):
		parent.set_layer_mask(layer)
	else:
		push_error("VTVisibilityComponent: Parent node does not have the set_layer_mask method.")

	# Propagate to children if enabled
	if propagate_to_children:
		_set_children_visibility(parent, layer)

func _set_children_visibility(node: Node, layer: int) -> void:
	for child in node.get_children():
		if child.has_method("set_layer_mask"):
			child.set_layer_mask(layer)
		_set_children_visibility(child, layer) # Recursive call for propagation
