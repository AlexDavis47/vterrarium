extends Control
class_name PackOpenUI

@export var item_card_container: ItemCardContainer


func _ready():
	for i in range(6):
		var creature = CreatureFactory.generate_creature_from_pool(CreatureFactory.CreaturePool.COMMON)
		item_card_container.add_item_card(creature)
