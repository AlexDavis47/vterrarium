extends Node
class_name UpgradeData

@export var upgrade_name: String = "Upgrade Name"
@export var upgrade_description: String = "Upgrade Description"
@export var upgrade_icon: Texture2D = preload("res://assets/icons/upgrade_icon.png")
@export var upgrade_cost: int = 1000