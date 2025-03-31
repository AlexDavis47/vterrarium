extends Control

@export var card_path: Path2D
@export var card_appearance_delay: float = 0.15
@export_range(0.0, 1.0, 0.05) var path_bounds: float = 0.8 # Percentage of path to use (centered)

var card_followers = []
var is_distributing = false

func _ready():
	# First, check if we have the required Path2D
	if not card_path:
		push_error("Card Path2D not assigned to ItemCardContainer!")
		return
	
	# Look for any direct children that are PackItemCardUI 
	# (cards added directly in the scene editor)
	var direct_cards = []
	for child in get_children():
		if child is PackItemCardUI:
			direct_cards.append(child)
	
	# Move existing cards to path followers
	for card in direct_cards:
		# Remove from direct parent but keep the node
		remove_child(card)
		
		# Create a path follower for it
		var path_follow = PathFollow2D.new()
		path_follow.loop = false
		path_follow.rotates = true
		path_follow.cubic_interp = true # Smoother movement along the path
		
		# Add to the path and set up the card
		card_path.add_child(path_follow)
		path_follow.add_child(card)
		
		# Reset the card's transform relative to its parent
		card.position = Vector2.ZERO
		card.rotation = 0
		card.scale = Vector2.ONE
		
		# Track the follower
		card_followers.append(path_follow)
	
	# Handle existing PathFollow2D with cards already set up properly
	for child in card_path.get_children():
		if child is PathFollow2D:
			var has_card = false
			for follower_child in child.get_children():
				if follower_child is PackItemCardUI:
					has_card = true
					break
					
			if has_card and not card_followers.has(child):
				card_followers.append(child)
	
	# Update the layout
	if card_followers.size() > 0:
		call_deferred("distribute_cards_with_animation")

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
	item_card.position = Vector2.ZERO
	item_card.rotation = 0
	item_card.scale = Vector2.ONE
	
	# Add to our list for tracking
	card_followers.append(path_follow)
	
	# Make card initially invisible and scale to zero
	item_card.modulate.a = 0
	item_card.scale = Vector2(0.1, 0.1)
	
	# Update positions of all cards and animate the new one in
	call_deferred("_update_layout")
	
	# Create appear animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(item_card, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(item_card, "scale", Vector2.ONE, 0.3)

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
	# Calculate the bounds
	var min_bound = (1.0 - path_bounds) / 2.0
	var max_bound = 1.0 - min_bound
	
	# Calculate progress within bounds
	var progress = min_bound
	if total_cards > 1:
		# Make sure to space evenly regardless of number of cards
		progress = min_bound + (float(index) / float(total_cards - 1)) * (max_bound - min_bound)
	
	return progress

func distribute_cards_with_animation():
	# Don't allow multiple distributions at once
	if is_distributing:
		return
		
	is_distributing = true
	
	# Set all cards to center
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
		
		# Set the z-index
		follower.z_index = num_cards - abs(i - (num_cards / 2))
		
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
