extends Control  # Or Panel, depending on what you used as the root

var duration = 1.0  # How long the notification stays visible

# Call this when you want to display and auto-remove the notification
func display(message):
	# Set the label text
	$Label.text = message
	
	# Start the auto-remove timer
	var timer = get_tree().create_timer(duration)
	await timer.timeout
	queue_free()
