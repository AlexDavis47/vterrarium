@tool
extends MarginContainer
class_name StoreItem

########################################################
# Exports
########################################################

@export var item_data: StoreItemData:
	get:
		return item_data
	set(value):
		if item_data:
			item_data.changed.disconnect(_update_ui)
		item_data = value
		if item_data:
			item_data.changed.connect(_update_ui)
		_update_ui()

@export var name_label: Label:
	get:
		return name_label
	set(value):
		name_label = value
		_update_ui()

@export var description_label: Label:
	get:
		return description_label
	set(value):
		description_label = value
		_update_ui()

@export var price_label: Label:
	get:
		return price_label
	set(value):
		price_label = value
		_update_ui()

@export var icon: TextureRect:
	get:
		return icon
	set(value):
		icon = value
		_update_ui()

@export var gradient: TextureRect:
	get:
		return gradient
	set(value):
		gradient = value
		_update_ui()

@export var purchase_button: TextureButton:
	get:
		return purchase_button
	set(value):
		if purchase_button:
			purchase_button.pressed.disconnect(_on_purchase_pressed)
		purchase_button = value
		if purchase_button:
			purchase_button.pressed.connect(_on_purchase_pressed)
		_update_ui()

########################################################
# Private Variables
########################################################

var _pack_opening_scene: PackedScene = preload("uid://bxqwq0gowno71")


########################################################
# Initialization
########################################################

func _ready():
	_update_ui()

########################################################
# Body
########################################################

func _update_ui():
	if not item_data:
		return
	_update_name_label()
	_update_description_label()
	_update_price_label()
	_update_icon()
	_update_gradient()


func _update_name_label():
	if name_label:
		name_label.text = item_data.item_name


func _update_description_label():
	if description_label:
		description_label.text = item_data.item_description


func _update_price_label():
	if price_label:
		price_label.text = str(item_data.item_price)


func _update_icon():
	if icon:
		icon.texture = item_data.item_icon


func _update_gradient():
	if gradient:
		gradient.modulate = item_data.item_color

########################################################
# Signal Handlers
########################################################

func _on_purchase_pressed():
	if item_data:
		item_data.purchase()
		_update_ui()
		open_pack()


func open_pack():
	var opening_instance: PackOpenUI = _pack_opening_scene.instantiate()
	opening_instance.pack_data = item_data.pack_data
	get_tree().root.add_child(opening_instance)
