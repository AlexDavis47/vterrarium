extends Control
class_name PackOpenUI

@export var item_card_container: ItemCardContainer
@export var animation: AnimationPlayer

var cards_to_add: Array[ItemDataResource] = []
var instantiated_cards: Array[PackItemCardUI] = []

func _ready() -> void:
	item_card_container.all_cards_taken.connect(_on_all_cards_taken)
	animation.play("open_pack")
	# We will pre-instantiate cards after they've all been added

func add_item_card(item: ItemDataResource) -> void:
	cards_to_add.append(item)

func prepare_cards() -> void:
	# Call this after all cards have been added to pre-instantiate them
	pre_instantiate_cards()

func pre_instantiate_cards() -> void:
	instantiated_cards.clear()
	for item in cards_to_add:
		var card: PackItemCardUI = item_card_container.instantiate_card()
		card.data = item
		# Prepare visuals (including preview instantiation) before adding to tree
		card.prepare_card_visuals()
		instantiated_cards.append(card)

func _on_all_cards_taken() -> void:
	animation.play("pack_close")

func _anim_add_all_cards() -> void:
	# If cards haven't been pre-instantiated yet, do it now
	if instantiated_cards.is_empty() and !cards_to_add.is_empty():
		pre_instantiate_cards()
		
	for card in instantiated_cards:
		item_card_container.add_instantiated_card(card)
	item_card_container.distribute_cards_with_animation()

func _anim_close() -> void:
	queue_free()
