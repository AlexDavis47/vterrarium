extends TextureRect
class_name AccessoriesContainer

########################################################
# Constants
########################################################

## The scene to instantiate for accessory cards
var card_scene: PackedScene = preload("uid://dpj42nvvwygow")

########################################################
# Signals
########################################################

## Emitted when an accessory is equipped to a creature
signal accessory_equipped(accessory_data: AccessoryData, creature_data: CreatureData)
## Emitted when an accessory is unequipped from a creature
signal accessory_unequipped(accessory_data: AccessoryData, creature_data: CreatureData)

########################################################
# Properties
########################################################

## Reference to the container for accessory cards
@export var card_container: HFlowContainer

## Data for the creature that accessories will be equipped to
var creature_data: CreatureData # Passed in from the parent

########################################################
# Private Variables
########################################################

## Dictionary of active accessory cards indexed by accessory_id
var existing_cards: Dictionary = {}

########################################################
# Methods
########################################################

## Updates the UI to reflect current accessory inventory
func update_ui() -> void:
	# Track which accessories are still valid to show
	var valid_accessory_ids = []
	
	# First pass: update existing cards or mark for removal
	for accessory in SaveManager.save_file.accessory_inventory:
		# If equipped to a different creature, don't show it
		if accessory.accessory_is_equipped and not accessory.creature_equipped_id == creature_data.creature_id:
			continue
			
		valid_accessory_ids.append(accessory.accessory_id)
		
		if existing_cards.has(accessory.accessory_id):
			# Update existing card
			var card = existing_cards[accessory.accessory_id]
			card.accessory_data = accessory
			card.creature_data = creature_data
			card.update_ui()
		else:
			# Create a new card
			var card = card_scene.instantiate()
			card.accessory_data = accessory
			card.creature_data = creature_data
			card.update_ui()
			card_container.add_child(card)
			
			card.accessory_equipped.connect(_on_accessory_equipped)
			card.accessory_unequipped.connect(_on_accessory_unequipped)
			card.request_update.connect(_on_request_update)
			
			existing_cards[accessory.accessory_id] = card
			
			card.modulate = Color(1, 1, 1, 0)
			var tween = card.create_tween()
			tween.tween_property(card, "modulate", Color(1, 1, 1, 1), 0.5)
			tween.set_trans(Tween.TRANS_QUAD)
			await get_tree().create_timer(0.05).timeout
	
	# Remove cards that are no longer valid
	var cards_to_remove = []
	for accessory_id in existing_cards:
		if not accessory_id in valid_accessory_ids:
			cards_to_remove.append(accessory_id)
	
	for accessory_id in cards_to_remove:
		var card = existing_cards[accessory_id]
		card_container.remove_child(card)
		card.queue_free()
		existing_cards.erase(accessory_id)

########################################################
# Signal Handlers
########################################################

## Called when a card requests an update
func _on_request_update() -> void:
	update_ui()

## Called when an accessory is equipped
func _on_accessory_equipped(accessory_data: AccessoryData, creature_data: CreatureData) -> void:
	accessory_equipped.emit(accessory_data, creature_data)

## Called when an accessory is unequipped
func _on_accessory_unequipped(accessory_data: AccessoryData, creature_data: CreatureData) -> void:
	accessory_unequipped.emit(accessory_data, creature_data)
