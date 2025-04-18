extends Control
class_name TextEntryUI

########################################################
# Signals
########################################################

## Emitted when the user confirms their input.
signal text_confirmed(text: String)

## Emitted when the user cancels their input
signal text_cancelled()

########################################################
# Exports
########################################################

@export_group("Configuration")
@export var prompt: String = "Enter text"
@export var text: String = ""
@export var placeholder: String = ""
@export var max_length: int = 20

@export_group("Components")
@export var prompt_label: Label
@export var line_edit: LineEdit
@export var cancel_button: TextureButton
@export var confirm_button: TextureButton
@export var remaining_characters_label: Label

########################################################
# Private Variables
########################################################

var _remaining_characters_label_min_color: Color = Color(0, 0.6352, 0.9921)
var _remaining_characters_label_max_color: Color = Color(0.9960, 0.3607, 0.3372)

########################################################
# Initialization
########################################################

func _ready():
	_initialize_line_edit()
	_initialize_buttons()
	_initialize_prompt_label()
	_update_remaining_characters_label()

func _initialize_line_edit():
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	line_edit.text_change_rejected.connect(_on_line_edit_text_change_rejected)
	line_edit.placeholder_text = placeholder
	line_edit.text = text
	line_edit.max_length = max_length

func _initialize_buttons():
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)

func _initialize_prompt_label():
	prompt_label.text = prompt

########################################################
# Helpers
########################################################

## Calculates the remaining characters for user entry and updates the label
## text and color based on the remaining characters.
func _update_remaining_characters_label():
	var characters_in_text: int = line_edit.text.length()

	var limit_percentage: float = float(characters_in_text) / float(max_length)

	var color: Color = _remaining_characters_label_min_color.lerp(_remaining_characters_label_max_color, limit_percentage)

	remaining_characters_label.text = str(characters_in_text) + "/" + str(max_length)
	remaining_characters_label.add_theme_color_override("font_color", color)

## Shakes the label to indicate an error
func _shake_label(label: Label):
	var original_position = label.position
	var tween = create_tween().set_parallel(true)
	
	# First shake right
	tween.tween_property(label, "position", original_position + Vector2(10, 0), 0.02)
	tween.chain().tween_property(label, "position", original_position, 0.02)
	
	# Then shake left
	tween.chain().tween_property(label, "position", original_position - Vector2(10, 0), 0.02)
	tween.chain().tween_property(label, "position", original_position, 0.02)


########################################################
# Signal Handlers
########################################################

func _on_line_edit_text_changed(_text: String):
	_update_remaining_characters_label()

func _on_line_edit_text_change_rejected(_text: String):
	_shake_label(remaining_characters_label)
	AudioManager.play_sfx(AudioManager.SFX.CANCEL_1)
	if line_edit.text.length() == 0:
		VTGlobal.display_notification("Please enter a name!")
	if line_edit.text.length() > max_length:
		VTGlobal.display_notification("Name is too long!")

func _on_confirm_button_pressed():
	AudioManager.play_sfx(AudioManager.SFX.POP_1, 0.8, 1.2)
	emit_signal("text_confirmed", line_edit.text)
	queue_free()

func _on_cancel_button_pressed():
	AudioManager.play_sfx(AudioManager.SFX.POP_1, 0.8, 1.2)
	emit_signal("text_cancelled")
	queue_free()
