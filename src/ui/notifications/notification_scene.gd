extends Panel  # Or Panel, depending on what you used as the root

var duration = 1.0  # How long the notification stays visible
var tween_duration = 0.5  # How long the sliding animation takes

# Call this when you want to display and auto-remove the notification
func display(message):
	# Set the label text
	$Label.text = message
	
	# Set initial position above screen
	var original_position = position
	position.y = original_position.y - size.y
	
	# Create tween for sliding in
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", original_position.y, tween_duration)
	
	# Wait for duration
	await get_tree().create_timer(duration).timeout
	
	# Create tween for sliding out
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", original_position.y - size.y, tween_duration)
	await tween.finished
	
	# Now remove the notification
	queue_free()
