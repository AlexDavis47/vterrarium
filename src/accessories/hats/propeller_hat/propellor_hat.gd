@tool
extends Node3D

@export var fan: Node3D


func _process(delta):
	fan.rotate_y(delta * 35)
