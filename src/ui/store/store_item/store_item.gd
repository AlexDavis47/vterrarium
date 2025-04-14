@tool
extends MarginContainer
class_name StoreItem

signal purchased(item_data: StoreItemData)


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
	SaveManager.save_file.money_changed.connect(_on_money_changed)

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
	_update_purchase_button()

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

func _update_purchase_button():
	if purchase_button:
		if SaveManager.save_file.money >= item_data.item_price:
			purchase_button.disabled = false
			purchase_button.modulate = Color(1, 1, 1, 1)
		else:
			purchase_button.disabled = true
			purchase_button.modulate = Color(1, 1, 1, 0.35)

func open_pack():
	var opening_instance: PackOpenUI = _pack_opening_scene.instantiate()
	var loot = LootGenerator.generate_loot(item_data.loot_table, item_data.number_of_items)
	for item in loot:
		opening_instance.add_item_card(item)
	get_tree().root.add_child(opening_instance)
	opening_instance.prepare_cards()

########################################################
# Signal Handlers
########################################################

func _on_purchase_pressed():
	AudioManager.play_sfx(AudioManager.SFX.POP_1, 0.8, 1.2)
	if item_data:
		if SaveManager.save_file.money >= item_data.item_price:
			SaveManager.save_file.money -= item_data.item_price
			_update_ui()
			open_pack()
			purchased.emit(item_data)
		else:
			pass

func _on_money_changed():
	_update_ui()
