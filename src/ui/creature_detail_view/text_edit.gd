extends TextEdit

func _ready():
	for child in get_children():
		if child is VScrollBar:
			remove_child(child)
		elif child is HScrollBar:
			remove_child(child)
