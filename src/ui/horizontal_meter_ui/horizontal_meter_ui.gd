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
		value = clamp(value, 0.0, max_value) # Ensure value stays within range
		queue_redraw()

## Meter fill amount (0.0 - 1.0)
@export_range(0.0, 1.0, 0.01) var fill_ratio: float = 0.5:
	set(new_value):
		fill_ratio = clamp(new_value, 0.0, 1.0)
		value = fill_ratio * max_value
		queue_redraw()

@export_group("Display")
## Label text displayed next to the meter
@export var label_text: String = "Happiness":
	set(new_value):
		label_text = new_value
		queue_redraw()

## Show label value as text (e.g. "50/100")
@export var show_value_text: bool = false:
	set(new_value):
		show_value_text = new_value
		queue_redraw()

## Format for the value text (e.g. "%d/%d" or "%.1f/%.1f")
@export var value_format: String = "%d/%d":
	set(new_value):
		value_format = new_value
		queue_redraw()

## Show percentage text (e.g. "50%")
@export var show_percentage: bool = false:
	set(new_value):
		show_percentage = new_value
		queue_redraw()

## Border color for the meter
@export var border_color: Color = Color(0.5, 0.5, 0.5, 1.0):
	set(new_value):
		border_color = new_value
		queue_redraw()

## Border width
@export_range(0.0, 10.0, 0.5) var border_width: float = 2.0:
	set(new_value):
		border_width = new_value
		queue_redraw()

## Background color for unfilled part
@export var background_color: Color = Color(0.2, 0.2, 0.2, 0.5):
	set(new_value):
		background_color = new_value
		queue_redraw()

## Corner radius for the meter
@export_range(0.0, 20.0, 1.0) var corner_radius: float = 5.0:
	set(new_value):
		corner_radius = new_value
		queue_redraw()

@export_group("Meter Fill")
## Use gradient fill for the meter
@export var use_gradient: bool = true:
	set(new_value):
		use_gradient = new_value
		queue_redraw()

## Single color fill (when not using gradient)
@export var fill_color: Color = Color(0.0, 0.7, 1.0, 1.0):
	set(new_value):
		fill_color = new_value
		queue_redraw()

## Left/start color for gradient fill
@export var gradient_start_color: Color = Color(1.0, 0.0, 0.0, 1.0):
	set(new_value):
		gradient_start_color = new_value
		queue_redraw()

## Middle color for gradient fill
@export var gradient_middle_color: Color = Color(1.0, 0.5, 0.0, 1.0):
	set(new_value):
		gradient_middle_color = new_value
		queue_redraw()

## Right/end color for gradient fill
@export var gradient_end_color: Color = Color(1.0, 0.9, 0.0, 1.0):
	set(new_value):
		gradient_end_color = new_value
		queue_redraw()

@export_group("Font")
## Label font size
@export_range(8, 72, 1) var label_font_size: int = 24:
	set(new_value):
		label_font_size = new_value
		queue_redraw()

## Label font color
@export var label_color: Color = Color(0.3, 0.5, 0.7, 1.0):
	set(new_value):
		label_color = new_value
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

@export_group("Layout")
## Padding around the meter
@export var padding: Vector2 = Vector2(5, 5):
	set(new_value):
		padding = new_value
		queue_redraw()

## Space between label and meter
@export_range(0, 50, 1) var label_spacing: int = 10:
	set(new_value):
		label_spacing = new_value
		queue_redraw()

## Label alignment (0=left, 1=above)
@export_enum("Left:0", "Above:1") var label_position: int = 0:
	set(new_value):
		label_position = new_value
		queue_redraw()

## Height of the meter bar
@export_range(5, 100, 1) var meter_height: int = 20:
	set(new_value):
		meter_height = new_value
		queue_redraw()

########################################################
# Private Variables
########################################################

## Font for labels
var _font: Font

########################################################
# Initialization
########################################################

func _ready() -> void:
	# Initialize font for labels
	_font = ThemeDB.fallback_font
	
	# Ensure custom minimum size
	custom_minimum_size = Vector2(200, 50)
	
	# Set initial fill ratio from value/max_value
	if max_value > 0:
		fill_ratio = value / max_value

########################################################
# Drawing
########################################################

func _draw() -> void:
	# Calculate fill ratio if it's not consistent with value
	if max_value > 0 and fill_ratio != value / max_value:
		fill_ratio = value / max_value
	
	var font = _font if _font else ThemeDB.fallback_font
	
	# Layout calculations
	var available_rect = Rect2(padding, size - padding * 2)
	var meter_rect: Rect2
	var label_pos: Vector2
	
	# Create meter_rect based on label position
	if label_position == 0: # Label on left
		var label_width = 0
		if label_text.length() > 0:
			label_width = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_font_size).x
			label_width += label_spacing
		
		label_pos = Vector2(available_rect.position.x, available_rect.position.y + (available_rect.size.y - label_font_size) / 2)
		
		meter_rect = Rect2(
			available_rect.position.x + label_width,
			available_rect.position.y + (available_rect.size.y - meter_height) / 2,
			available_rect.size.x - label_width,
			meter_height
		)
	else: # Label above
		var label_height = 0
		if label_text.length() > 0:
			label_height = label_font_size + label_spacing
		
		label_pos = Vector2(available_rect.position.x, available_rect.position.y)
		
		meter_rect = Rect2(
			available_rect.position.x,
			available_rect.position.y + label_height,
			available_rect.size.x,
			meter_height
		)
	
	# Draw the label
	if label_text.length() > 0:
		draw_string(font, label_pos, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, label_font_size, label_color)
	
	# Draw meter background (unfilled part)
	if corner_radius > 0:
		draw_rect(meter_rect, background_color, true, corner_radius)
	else:
		draw_rect(meter_rect, background_color, true)
	
	# Draw filled part of meter
	if fill_ratio > 0:
		var fill_rect = Rect2(
			meter_rect.position,
			Vector2(meter_rect.size.x * fill_ratio, meter_rect.size.y)
		)
		
		if use_gradient:
			# Create gradient texture
			var gradient = Gradient.new()
			gradient.add_point(0.0, gradient_start_color)
			gradient.add_point(0.5, gradient_middle_color)
			gradient.add_point(1.0, gradient_end_color)
			
			var gradient_texture = GradientTexture2D.new()
			gradient_texture.gradient = gradient
			gradient_texture.width = int(meter_rect.size.x)
			gradient_texture.height = int(meter_rect.size.y)
			gradient_texture.fill = GradientTexture2D.FILL_LINEAR
			gradient_texture.fill_from = Vector2(0, 0.5)
			gradient_texture.fill_to = Vector2(1, 0.5)
			
			# Draw filled part with gradient
			if corner_radius > 0:
				draw_texture_rect_region(
					gradient_texture,
					fill_rect,
					Rect2(0, 0, fill_rect.size.x, fill_rect.size.y),
					Color(1, 1, 1, 1),
					false,
					corner_radius
				)
			else:
				draw_texture_rect_region(
					gradient_texture,
					fill_rect,
					Rect2(0, 0, fill_rect.size.x, fill_rect.size.y),
					Color(1, 1, 1, 1)
				)
		else:
			# Single color fill
			if corner_radius > 0:
				draw_rect(fill_rect, fill_color, true, corner_radius)
			else:
				draw_rect(fill_rect, fill_color, true)
	
	# Draw border
	if border_width > 0:
		if corner_radius > 0:
			draw_rect(meter_rect, border_color, false, corner_radius, border_width)
		else:
			draw_rect(meter_rect, border_color, false, 0, border_width)
	
	# Draw value text
	if show_value_text or show_percentage:
		var text_to_draw = ""
		
		if show_value_text:
			text_to_draw = value_format % [value, max_value]
		
		if show_percentage:
			var percentage = int(fill_ratio * 100)
			if text_to_draw.length() > 0:
				text_to_draw += " "
			text_to_draw += "%d%%" % percentage
		
		if text_to_draw.length() > 0:
			var text_size = font.get_string_size(text_to_draw, HORIZONTAL_ALIGNMENT_CENTER, -1, value_font_size)
			var text_pos = Vector2(
				meter_rect.position.x + meter_rect.size.x / 2 - text_size.x / 2,
				meter_rect.position.y + meter_rect.size.y / 2 + text_size.y / 4
			)
			
			draw_string(font, text_pos, text_to_draw, HORIZONTAL_ALIGNMENT_CENTER, -1, value_font_size, value_color)

########################################################
# Public Methods
########################################################

## Set value directly and update display
func set_value(new_value: float) -> void:
	value = clamp(new_value, 0.0, max_value)
	fill_ratio = value / max_value if max_value > 0 else 0
	queue_redraw()

## Set both value and max value
func set_values(new_value: float, new_max_value: float) -> void:
	max_value = max(0.1, new_max_value)
	value = clamp(new_value, 0.0, max_value)
	fill_ratio = value / max_value
	queue_redraw()

## Animate the meter value change
func animate_value(new_value: float, duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(self, "value", new_value, duration)
