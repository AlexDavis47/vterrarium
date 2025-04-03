extends Control
class_name PackOpenUI

@export var item_card_container: ItemCardContainer
@export var animation: AnimationPlayer

var cards_to_add: Array[ItemDataResource] = []

func _ready() -> void:
	item_card_container.all_cards_taken.connect(_on_all_cards_taken)
	animation.play("open_pack")

func add_item_card(item: ItemDataResource) -> void:
	cards_to_add.append(item)

func _on_all_cards_taken() -> void:
	animation.play("pack_close")


func _anim_add_all_cards() -> void:
	for item in cards_to_add:
		item_card_container.add_item_card(item)
	item_card_container.distribute_cards_with_animation()

func _anim_close() -> void:
	queue_free()
