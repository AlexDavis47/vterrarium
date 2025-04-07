@tool
extends Control
class_name HorizontalMeterUI

########################################################
# Exports
########################################################

@export_group("Core")
## Current value of the meter
@export_range(0.0, 10000.0, 0.1) var value: float = 50.0:
	set(new_value):
		value = clamp(new_value, 0.0, max_value)
		queue_redraw()

## Maximum value the meter can have
@export_range(0.1, 10000.0, 0.1) var max_value: float = 100.0:
	set(new_value):
		max_value = max(0.1, new_value)
		value = clamp(value, 0.0, max_value)
		queue_redraw()

@export_group("Meter Fill")
## Left/start color for gradient fill
@export var gradient_start_color: Color = Color(1.0, 0.0, 0.0, 1.0):
	set(new_value):
		gradient_start_color = new_value
		_update_gradient_texture()
		queue_redraw()

## Middle color for gradient fill
@export var gradient_middle_color: Color = Color(1.0, 0.5, 0.0, 1.0):
	set(new_value):
		gradient_middle_color = new_value
		_update_gradient_texture()
		queue_redraw()

## Right/end color for gradient fill
@export var gradient_end_color: Color = Color(1.0, 0.9, 0.0, 1.0):
	set(new_value):
		gradient_end_color = new_value
		_update_gradient_texture()
		queue_redraw()

@export_group("Background")
## Top-left corner color for background gradient
@export var bg_top_left_color: Color = Color(0.1, 0.1, 0.2, 0.2):
	set(new_value):
		bg_top_left_color = new_value
		queue_redraw()

## Top-right corner color for background gradient
@export var bg_top_right_color: Color = Color(0.1, 0.2, 0.3, 0.2):
	set(new_value):
		bg_top_right_color = new_value
		queue_redraw()

## Bottom-left corner color for background gradient
@export var bg_bottom_left_color: Color = Color(0.2, 0.1, 0.1, 0.2):
	set(new_value):
		bg_bottom_left_color = new_value
		queue_redraw()

## Bottom-right corner color for background gradient
@export var bg_bottom_right_color: Color = Color(0.3, 0.2, 0.1, 0.2):
	set(new_value):
		bg_bottom_right_color = new_value
		queue_redraw()

@export_group("Value Display")
## Show value text (e.g. "50/100")
@export var show_value_text: bool = true:
	set(new_value):
		show_value_text = new_value
		queue_redraw()

## Show percentage text (e.g. "50%")
@export var show_percentage: bool = true:
	set(new_value):
		show_percentage = new_value
		queue_redraw()

## Value font size
@export_range(8, 72, 1) var value_font_size: int = 16:
	set(new_value):
		value_font_size = new_value
		queue_redraw()

## Value font color
@export var value_color: Color = Color(1.0, 1.0, 1.0, 1.0):
	set(new_value):
		value_color = new_value
		queue_redraw()

########################################################
# Private Variables
########################################################

## Font for labels
var _font: Font

## Cached gradient texture
var _gradient_texture: GradientTexture2D

########################################################
# Initialization
########################################################

func _ready() -> void:
	# Initialize font for labels
	_font = ThemeDB.fallback_font
	
	# Ensure custom minimum size
	custom_minimum_size = Vector2(200, 30)
	
	# Create initial gradient texture
	_update_gradient_texture()

func _update_gradient_texture() -> void:
	# Create gradient
	var gradient = Gradient.new()
	gradient.add_point(0.0, gradient_start_color)
	gradient.add_point(0.5, gradient_middle_color)
	gradient.add_point(1.0, gradient_end_color)
	
	# Create texture
	_gradient_texture = GradientTexture2D.new()
	_gradient_texture.gradient = gradient
	_gradient_texture.width = 256 # Fixed size for the texture
	_gradient_texture.height = 1 # Only need 1 pixel height
	_gradient_texture.fill = GradientTexture2D.FILL_LINEAR
	_gradient_texture.fill_from = Vector2(0, 0)
	_gradient_texture.fill_to = Vector2(1, 0)

########################################################
# Drawing
########################################################

func _draw() -> void:
	var font = _font if _font else ThemeDB.fallback_font
	
	# Calculate fill ratio
	var fill_ratio = value / max_value if max_value > 0 else 0
	
	# Draw background gradient
	var bg_colors = PackedColorArray([
		bg_top_left_color,
		bg_top_right_color,
		bg_bottom_right_color,
		bg_bottom_left_color
	])
	var bg_points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y)
	])
	draw_polygon(bg_points, bg_colors)
	
	# Draw filled part of meter
	if fill_ratio > 0 and _gradient_texture:
		var fill_width = size.x * fill_ratio
		
		# Draw the gradient fill
		draw_texture_rect(
			_gradient_texture,
			Rect2(0, 0, fill_width, size.y),
			false,
			Color(1, 1, 1, 1)
		)
	
	# Draw value text
	if show_value_text or show_percentage:
		var text_to_draw = ""
		
		if show_value_text:
			text_to_draw = "%d/%d" % [value, max_value]
		
		if show_percentage:
			var percentage = int(fill_ratio * 100)
			if text_to_draw.length() > 0:
				text_to_draw += " "
			text_to_draw += "%d%%" % percentage
		
		if text_to_draw.length() > 0:
			var text_size = font.get_string_size(text_to_draw, HORIZONTAL_ALIGNMENT_CENTER, -1, value_font_size)
			var text_pos = Vector2(
				size.x / 2 - text_size.x / 2,
				size.y / 2 + text_size.y / 4
			)
			
			draw_string(font, text_pos, text_to_draw, HORIZONTAL_ALIGNMENT_CENTER, -1, value_font_size, value_color)

########################################################
# Public Methods
########################################################

## Set value directly and update display
func set_value(new_value: float) -> void:
	value = clamp(new_value, 0.0, max_value)
	queue_redraw()

## Set both value and max value
func set_values(new_value: float, new_max_value: float) -> void:
	max_value = max(0.1, new_max_value)
	value = clamp(new_value, 0.0, max_value)
	queue_redraw()

## Animate the meter value change
func animate_value(new_value: float, duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(self, "value", new_value, duration)
