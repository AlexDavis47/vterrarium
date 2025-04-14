extends Control
class_name ItemCardContainer

signal all_cards_taken()

@export var card_path: Path2D
@export var card_appearance_delay: float = 0.15
@export_range(0.0, 1.0, 0.05) var path_bounds: float = 0.8 # Percentage of path to use (centered)

var card_followers = []
var is_distributing = false

var card: PackedScene = preload("uid://dd6syx0hetv05")


func _ready():
	# First, check if we have the required Path2D
	if not card_path:
		push_error("Card Path2D not assigned to ItemCardContainer!")
		return
	
	# Explicitly call the animation distribution after adding all cards
	call_deferred("distribute_cards_with_animation")

# Instantiates a card without adding it to the scene
func instantiate_card() -> PackItemCardUI:
	var item_card = card.instantiate()
	return item_card
	
# Adds a pre-instantiated card to the container
func add_instantiated_card(item_card: PackItemCardUI) -> void:
	_add_item_card(item_card)
	
func _add_item_card(item_card: PackItemCardUI):
	# Create a new PathFollow2D to follow the path
	var path_follow = PathFollow2D.new()
	path_follow.loop = false
	path_follow.rotates = true
	path_follow.cubic_interp = true # Smoother movement along the path
	
	# Set initial progress to center
	path_follow.progress_ratio = 0.5
	
	# Add the PathFollow2D to the path
	card_path.add_child(path_follow)
	
	# Add the card as a child of the PathFollow2D
	path_follow.add_child(item_card)
	
	# Reset the card's transform relative to its parent
	item_card.position = - item_card.size / 2
	item_card.rotation = 0
	item_card.scale = Vector2(0.1, 0.1)
	item_card.modulate.a = 0

	item_card.item_taken.connect(_on_item_taken)
	
	# Add to our list for tracking
	card_followers.append(path_follow)
	
	# Don't update layout immediately for each card
	# Let distribute_cards_with_animation handle the initial layout
	if card_followers.size() > 6:
		# Only update layout if we're adding cards after initial setup
		call_deferred("_update_layout")
		
		# Create appear animation only for individual cards added later
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(item_card, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(item_card, "scale", Vector2.ONE, 0.3)

func add_item_card(data: ItemDataResource) -> PackItemCardUI:
	if !data:
		return null
	var item_card = card.instantiate()
	item_card.data = data
	_add_item_card(item_card)
	return item_card


func _remove_item_card(item_card: PackItemCardUI):
	# Find the PathFollow2D parent of this card
	var path_follow = item_card.get_parent()
	if path_follow is PathFollow2D:
		# Remove from our list
		card_followers.erase(path_follow)
		
		# Free the card and its follower
		path_follow.queue_free()
		
		# Update positions of remaining cards
		call_deferred("_update_layout")
	else:
		# Fallback if structure isn't as expected
		item_card.queue_free()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		call_deferred("_update_layout")

# Calculate the path progress value based on the index, count, and bounds
func _calculate_progress(index: int, total_cards: int) -> float:
	# Define the number of cards at which the full spread is used
	const MAX_CARDS_FOR_FULL_SPREAD = 6

	# Calculate the center point
	var center_progress = 0.5

	# Handle single card case
	if total_cards <= 1:
		return center_progress # Single card always at the center

	# Calculate the scaling factor based on the number of cards
	var scale_factor = 1.0
	if MAX_CARDS_FOR_FULL_SPREAD > 1:
		# Clamp prevents scale_factor > 1 if total_cards > MAX_CARDS_FOR_FULL_SPREAD
		# Use total_cards directly for ratio, so max cards uses full spread
		scale_factor = clampf(float(total_cards) / float(MAX_CARDS_FOR_FULL_SPREAD), 0.0, 1.0)
	# else: scale_factor remains 1.0 if MAX_CARDS_FOR_FULL_SPREAD is 1 or less

	# Calculate the effective width and the starting bound (min) based on scaling
	var effective_width = path_bounds * scale_factor
	var effective_min_bound = center_progress - effective_width / 2.0

	# Calculate progress within the effective bounds
	# Ensure float division to avoid issues when total_cards is 2
	# The distribution happens across the effective_width
	var progress = effective_min_bound
	if total_cards > 1: # Add check again to be safe, although already handled above
		progress = effective_min_bound + (float(index) / float(total_cards - 1)) * effective_width

	# Original calculation commented out for reference:
	# var min_bound = (1.0 - path_bounds) / 2.0
	# var max_bound = 1.0 - min_bound
	# var progress_original = min_bound
	# if total_cards > 1:
	#     progress_original = min_bound + (float(index) / float(total_cards - 1)) * (max_bound - min_bound)

	return progress

func distribute_cards_with_animation():
	# Don't allow multiple distributions at once
	if is_distributing:
		return
		
	is_distributing = true
	
	# Set all cards to center initially
	for follower in card_followers:
		if is_instance_valid(follower):
			# Hide cards initially
			for child in follower.get_children():
				if child is PackItemCardUI:
					child.modulate.a = 0
					child.scale = Vector2(0.1, 0.1)
			
			# Start at center
			follower.progress_ratio = 0.5
	
	# Delay before starting distribution
	await get_tree().create_timer(0.2).timeout
	
	# Update the layout with delays for each card
	var num_cards = card_followers.size()
	
	for i in range(num_cards):
		var follower = card_followers[i]
		if not is_instance_valid(follower):
			continue
			
		# Calculate final progress value with bounds
		var progress = _calculate_progress(i, num_cards)
		
		# Make the card visible with animation
		for child in follower.get_children():
			if child is PackItemCardUI:
				AudioManager.play_sfx(AudioManager.SFX.POP_1, 0.8, 1.2)

				var appear_tween = create_tween()
				appear_tween.set_ease(Tween.EASE_OUT)
				appear_tween.set_trans(Tween.TRANS_BACK)
				appear_tween.tween_property(child, "modulate:a", 1.0, 0.3)
				appear_tween.parallel().tween_property(child, "scale", Vector2.ONE, 0.3)
		
		# Animate to final position
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(follower, "progress_ratio", progress, 0.5)
		
		# follower.z_index = num_cards - abs(i - (num_cards / 2))
		
		# Mark as initialized
		follower.set_meta("initialized", true)
		
		# Wait before next card
		await get_tree().create_timer(card_appearance_delay).timeout
	
	is_distributing = false

func _update_layout():
	var num_cards = card_followers.size()
	if num_cards == 0:
		return
		
	# If we're in the middle of a distribute animation, don't update
	if is_distributing:
		return
	
	# Calculate positions along the path
	for i in range(num_cards):
		var follower = card_followers[i]
		if not is_instance_valid(follower):
			continue
		
		# Calculate progress value with bounds
		var progress = _calculate_progress(i, num_cards)
		
		# Apply with tween for smooth movement
		if follower.has_meta("initialized"):
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(follower, "progress_ratio", progress, 0.3)
		else:
			# First time positioning, just set directly
			follower.progress_ratio = progress
			follower.set_meta("initialized", true)
			
		# Set z-index for proper layering
		# Cards in the middle appear on top
		var z_index_value = num_cards - abs(i - (num_cards / 2))
		follower.z_index = z_index_value

func _on_item_taken(item_card: PackItemCardUI):
	# Find the card that was taken
	for follower in card_followers:
		for child in follower.get_children():
			if child is PackItemCardUI and child == item_card:
				# Remove the card from the container
				_remove_item_card(child)
				if card_followers.size() == 0:
					all_cards_taken.emit()
				break
