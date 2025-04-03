extends Control
class_name PackOpenUI

@export var item_card_container: ItemCardContainer

func _ready() -> void:
	item_card_container.all_cards_taken.connect(_on_all_cards_taken)

func add_item_card(item: ItemDataResource) -> void:
	item_card_container.add_item_card(item)

func _on_all_cards_taken() -> void:
	queue_free()
