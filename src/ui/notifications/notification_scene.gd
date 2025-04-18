extends PanelContainer
class_name Notification

const NOTIFICATION_DURATION = 2.0
const NOTIFICATION_TWEEN_DURATION = 0.5

@export var label: Label

# Call this when you want to display and auto-remove the notification
func display(message):
	# Set the label text
	label.text = message
	
	# Set initial position above screen and transparency
	var original_position = position
	position.y = original_position.y - size.y
	modulate.a = 0
	
	# Create tween for sliding in and fading in
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", original_position.y, NOTIFICATION_TWEEN_DURATION)
	tween.parallel().tween_property(self, "modulate:a", 1.0, NOTIFICATION_TWEEN_DURATION)
	
	# Wait for duration
	await get_tree().create_timer(NOTIFICATION_DURATION).timeout
	
	# Create tween for sliding out and fading out
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", original_position.y - size.y, NOTIFICATION_TWEEN_DURATION)
	tween.parallel().tween_property(self, "modulate:a", 0.0, NOTIFICATION_TWEEN_DURATION)
	await tween.finished
	
	# Now remove the notification
	queue_free()
