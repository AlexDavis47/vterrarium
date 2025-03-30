@tool
extends Control
class_name ValueMonitorMeterUI

########################################################
# Exports
########################################################

@export_group("Core")
## The current value to display
@export_range(0.0, 100.0, 0.01) var value: float = 0.0:
	set(new_value):
		var old_value = value
		value = clamp(new_value, min_value, max_value)
		
		if animate_value_changes and old_value != value:
			_start_animation(old_value, value)
		else:
			_displayed_value = value
		
		_request_redraw()

## Canvas where the meter is drawn
@export var meter_canvas: Control:
	set(new_canvas):
		if meter_canvas:
			if meter_canvas.is_connected("draw", _on_canvas_draw):
				meter_canvas.disconnect("draw", _on_canvas_draw)
		
		meter_canvas = new_canvas
		
		if meter_canvas:
			if not meter_canvas.is_connected("draw", _on_canvas_draw):
				meter_canvas.connect("draw", _on_canvas_draw)
			
			meter_canvas.z_index = 1

@export_group("Range")
## Minimum value of the meter
@export var min_value: float = 0.0:
	set(new_min):
		min_value = new_min
		value = clamp(value, min_value, max_value)
		_request_redraw()

## Maximum value of the meter
@export var max_value: float = 100.0:
	set(new_max):
		max_value = new_max
		value = clamp(value, min_value, max_value)
		_request_redraw()

## Warning threshold (value turns yellow above this)
@export var warning_threshold: float = 70.0:
	set(new_threshold):
		warning_threshold = new_threshold
		_request_redraw()

## Critical threshold (value turns red above this)
@export var critical_threshold: float = 90.0:
	set(new_threshold):
		critical_threshold = new_threshold
		_request_redraw()

@export_group("Display")
## Type of meter to display
@export_enum("Horizontal Bar", "Vertical Bar", "Radial Gauge") var meter_type: int = 0:
	set(new_type):
		meter_type = new_type
		_request_redraw()

## The unit to display after the value (e.g., "°C", "%", etc.)
@export var unit: String = "":
	set(new_unit):
		unit = new_unit
		_request_redraw()

## Title displayed above the meter
@export var title: String = "Value":
	set(new_title):
		title = new_title
		_request_redraw()

## True padding around the content (not affecting background)
@export var content_padding: Vector2 = Vector2(20, 20):
	set(new_padding):
		content_padding = new_padding
		_request_redraw()

## Thickness of the meter bar (relative to size)
@export_range(0.05, 0.5, 0.01) var meter_thickness_ratio: float = 0.2:
	set(new_ratio):
		meter_thickness_ratio = new_ratio
		_request_redraw()

## Number of decimal places to show
@export_range(0, 4, 1) var decimal_places: int = 1:
	set(new_places):
		decimal_places = new_places
		_request_redraw()

@export_group("Colors")
## Background color for the meter
@export var background_color: Color = Color("DEDEDE"):
	set(new_color):
		background_color = new_color
		_request_redraw()

## Text color for labels and values
@export var text_color: Color = Color("365D73"):
	set(new_color):
		text_color = new_color
		_request_redraw()

## Color gradient for the meter
@export var color_gradient: GradientTexture1D:
	set(new_gradient):
		color_gradient = new_gradient
		_request_redraw()
		
## Empty meter background color
@export var meter_bg_color: Color = Color(0.2, 0.2, 0.2, 0.3):
	set(new_color):
		meter_bg_color = new_color
		_request_redraw()

@export_group("Animation")
## Whether to animate value changes
@export var animate_value_changes: bool = true:
	set(new_animate):
		animate_value_changes = new_animate

## Animation speed (seconds for full transition)
@export_range(0.1, 2.0, 0.1) var animation_speed: float = 0.5:
	set(new_speed):
		animation_speed = new_speed

@export_group("Ticks and Labels")
## Show min/max labels
@export var show_min_max: bool = true:
	set(new_show):
		show_min_max = new_show
		_request_redraw()

## Show tick marks on the meter
@export var show_ticks: bool = true:
	set(new_show):
		show_ticks = new_show
		_request_redraw()

## Number of tick marks to display
@export_range(2, 20, 1) var num_ticks: int = 5:
	set(new_ticks):
		num_ticks = new_ticks
		_request_redraw()

@export_group("Font Settings")
## Title font size (relative to control size)
@export_range(0.03, 0.1, 0.005) var title_font_size_ratio: float = 0.06:
	set(new_ratio):
		title_font_size_ratio = new_ratio
		_request_redraw()

## Value font size (relative to control size)
@export_range(0.03, 0.1, 0.005) var value_font_size_ratio: float = 0.08:
	set(new_ratio):
		value_font_size_ratio = new_ratio
		_request_redraw()

## Label font size (relative to control size)
@export_range(0.02, 0.08, 0.005) var label_font_size_ratio: float = 0.04:
	set(new_ratio):
		label_font_size_ratio = new_ratio
		_request_redraw()

########################################################
# Private Variables
########################################################

## Currently displayed value (may differ from actual value during animation)
var _displayed_value: float = 0.0

## Animation tween
var _tween: Tween

## Font for text rendering
var _font: Font

## Default gradient if none is provided
var _default_gradient: Gradient

########################################################
# Initialization
########################################################

func _ready() -> void:
	# Initialize font
	_font = ThemeDB.fallback_font
	
	_displayed_value = value
	
	# Create default gradient if none is provided
	if not color_gradient:
		_create_default_gradient()
	
	# Setup canvas if available
	if meter_canvas:
		if not meter_canvas.is_connected("draw", _on_canvas_draw):
			meter_canvas.connect("draw", _on_canvas_draw)
		
		meter_canvas.z_index = 1
		meter_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_request_redraw()

func _process(delta: float) -> void:
	# Redraw in editor to see changes
	if Engine.is_editor_hint():
		_request_redraw()

## Create a default gradient with blue->yellow->red
func _create_default_gradient() -> void:
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color("00A2FD")) # Normal (blue)
	gradient.add_point(0.7, Color(1.0, 0.75, 0.0)) # Warning (yellow)
	gradient.add_point(1.0, Color(1.0, 0.2, 0.2)) # Critical (red)
	
	var texture = GradientTexture1D.new()
	texture.gradient = gradient
	color_gradient = texture

########################################################
# Drawing
########################################################

## Request redraw of the canvas
func _request_redraw() -> void:
	if meter_canvas:
		meter_canvas.queue_redraw()
	else:
		queue_redraw()

## Canvas draw callback
func _on_canvas_draw() -> void:
	if meter_canvas == null:
		return
	
	_draw_meter(meter_canvas)

## Draw method override for when no canvas is assigned
func _draw() -> void:
	if meter_canvas == null:
		_draw_meter(self)

## Main drawing function
func _draw_meter(canvas: Control) -> void:
	# Get total size
	var total_size = canvas.get_size()
	
	# Draw background for entire control
	canvas.draw_rect(Rect2(Vector2.ZERO, total_size), background_color)
	
	# Calculate the content area with padding
	var content_rect = Rect2(content_padding, total_size - content_padding * 2)
	
	# Skip drawing if area is too small
	if content_rect.size.x <= 0 or content_rect.size.y <= 0:
		return
	
	# Draw title
	var title_height = 0
	if title:
		title_height = _draw_title(canvas, content_rect)
	
	# Draw the meter based on type
	match meter_type:
		0: # Horizontal bar
			_draw_horizontal_meter(canvas, content_rect, title_height)
		1: # Vertical bar
			_draw_vertical_meter(canvas, content_rect, title_height)
		2: # Radial gauge
			_draw_radial_meter(canvas, content_rect, title_height)

## Draw the title and return height used
func _draw_title(canvas: Control, content_rect: Rect2) -> float:
	var font_size = int(content_rect.size.y * title_font_size_ratio)
	font_size = max(10, font_size) # Ensure minimum readable size
	
	# Create more space between title and meter (increased from 2.0 to 2.5)
	var title_height = font_size * 2.5
	
	# Calculate text width for proper centering
	var text_width = _font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	
	# Position the text explicitly centered
	var pos = Vector2(
		content_rect.position.x + (content_rect.size.x - text_width) / 2,
		content_rect.position.y + font_size
	)
	
	# Draw with explicit positioning
	canvas.draw_string(_font, pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
	
	return title_height

## Get meter color from gradient based on normalized value
func _get_meter_color(normalized_value: float) -> Color:
	if color_gradient:
		return color_gradient.gradient.sample(normalized_value)
	else:
		# Fallback if no gradient
		return Color("00A2FD")

## Draw horizontal bar meter
func _draw_horizontal_meter(canvas: Control, content_rect: Rect2, title_height: float) -> void:
	# Reserve space for title and value display
	var value_font_size = int(content_rect.size.y * value_font_size_ratio)
	value_font_size = max(12, value_font_size) # Minimum readable size
	var value_height = value_font_size * 1.5
	
	# Calculate available height for meter
	var available_height = content_rect.size.y - title_height - value_height
	
	# Calculate meter bar height (as a proportion of available height)
	var meter_height = min(available_height * 0.5, available_height - 20)
	meter_height = max(6, meter_height) # Ensure minimum visible height
	
	# Meter bar rect (centered vertically in the remaining space)
	var meter_y = content_rect.position.y + title_height + (available_height - meter_height) / 2
	var meter_rect = Rect2(
		content_rect.position.x,
		meter_y,
		content_rect.size.x,
		meter_height
	)
	
	# Draw meter background
	canvas.draw_rect(meter_rect, meter_bg_color)
	
	# Calculate fill amount
	var normalized_value = (_displayed_value - min_value) / (max_value - min_value)
	normalized_value = clamp(normalized_value, 0.0, 1.0)
	var fill_width = meter_rect.size.x * normalized_value
	
	# Draw filled portion
	if fill_width > 0:
		var fill_rect = Rect2(
			meter_rect.position,
			Vector2(fill_width, meter_rect.size.y)
		)
		canvas.draw_rect(fill_rect, _get_meter_color(normalized_value))
	
	# Draw tick marks
	if show_ticks:
		_draw_horizontal_ticks(canvas, meter_rect)
	
	# Draw min/max labels
	if show_min_max:
		_draw_horizontal_min_max(canvas, meter_rect)
	
	# Draw value text
	_draw_value_text(canvas, content_rect, meter_rect.position.y + meter_rect.size.y + value_height / 2)

## Draw vertical bar meter
func _draw_vertical_meter(canvas: Control, content_rect: Rect2, title_height: float) -> void:
	# Reserve space for title and value display
	var value_font_size = int(content_rect.size.y * value_font_size_ratio)
	value_font_size = max(12, value_font_size) # Minimum readable size
	var value_height = value_font_size * 1.5
	
	# Calculate available height for meter
	var available_height = content_rect.size.y - title_height - value_height
	
	# Calculate meter width based on ratio
	var meter_width = content_rect.size.x * meter_thickness_ratio
	meter_width = clamp(meter_width, 10, content_rect.size.x / 3) # Reasonable bounds
	
	# Meter bar rect (centered horizontally)
	var meter_rect = Rect2(
		content_rect.position.x + (content_rect.size.x - meter_width) / 2,
		content_rect.position.y + title_height,
		meter_width,
		available_height
	)
	
	# Draw meter background
	canvas.draw_rect(meter_rect, meter_bg_color)
	
	# Calculate fill amount (from bottom to top)
	var normalized_value = (_displayed_value - min_value) / (max_value - min_value)
	normalized_value = clamp(normalized_value, 0.0, 1.0)
	var fill_height = meter_rect.size.y * normalized_value
	
	# Draw filled portion (from bottom)
	if fill_height > 0:
		var fill_rect = Rect2(
			Vector2(meter_rect.position.x, meter_rect.position.y + meter_rect.size.y - fill_height),
			Vector2(meter_rect.size.x, fill_height)
		)
		canvas.draw_rect(fill_rect, _get_meter_color(normalized_value))
	
	# Draw tick marks
	if show_ticks:
		_draw_vertical_ticks(canvas, meter_rect)
	
	# Draw min/max labels
	if show_min_max:
		_draw_vertical_min_max(canvas, meter_rect)
	
	# Draw value text
	_draw_value_text(canvas, content_rect, content_rect.position.y + content_rect.size.y - value_height / 2)

## Draw radial gauge meter
func _draw_radial_meter(canvas: Control, content_rect: Rect2, title_height: float) -> void:
	# Reserve space for title and value display
	var value_font_size = int(content_rect.size.y * value_font_size_ratio)
	value_font_size = max(12, value_font_size) # Minimum readable size
	var value_height = value_font_size * 1.5
	
	# Calculate available height
	var available_height = content_rect.size.y - title_height - value_height
	
	# Calculate center and radius
	var center = Vector2(
		content_rect.position.x + content_rect.size.x / 2,
		content_rect.position.y + title_height + available_height / 2
	)
	
	# Use the smaller dimension for the radius to ensure it fits
	var max_radius_w = content_rect.size.x / 2 * 0.9
	var max_radius_h = available_height / 2 * 0.9
	var radius = min(max_radius_w, max_radius_h)
	
	# Calculate arc thickness based on the meter thickness ratio
	var arc_thickness = radius * meter_thickness_ratio
	arc_thickness = clamp(arc_thickness, 5, radius / 3)
	
	# Draw meter background (arc from 135° to 405° or -45°)
	var start_angle = deg_to_rad(135)
	var end_angle = deg_to_rad(405)
	canvas.draw_arc(center, radius, start_angle, end_angle, 32, meter_bg_color, arc_thickness, true)
	
	# Calculate fill angle
	var normalized_value = (_displayed_value - min_value) / (max_value - min_value)
	normalized_value = clamp(normalized_value, 0.0, 1.0)
	var fill_angle = start_angle + normalized_value * (end_angle - start_angle)
	
	# Draw filled portion
	if normalized_value > 0:
		canvas.draw_arc(center, radius, start_angle, fill_angle, 32,
						_get_meter_color(normalized_value), arc_thickness, true)
	
	# Draw tick marks
	if show_ticks:
		_draw_radial_ticks(canvas, center, radius, start_angle, end_angle)
	
	# Draw min/max labels
	if show_min_max:
		_draw_radial_min_max(canvas, center, radius, start_angle, end_angle)
	
	# Draw needle
	_draw_radial_needle(canvas, center, radius, start_angle, fill_angle)
	
	# Draw center cap
	canvas.draw_circle(center, arc_thickness * 0.5, _get_meter_color(normalized_value))
	
	# Draw value text
	_draw_value_text(canvas, content_rect, center.y + radius + value_height / 2)

## Draw horizontal meter tick marks
func _draw_horizontal_ticks(canvas: Control, meter_rect: Rect2) -> void:
	var size_ratio = meter_rect.size.y / 100.0 # Base tick size on meter height
	var tick_length = clamp(meter_rect.size.y * 0.4, 5, 20)
	
	# Calculate label font size
	var label_font_size = int(meter_rect.size.y * label_font_size_ratio * 2)
	label_font_size = clamp(label_font_size, 8, 16)
	
	for i in range(num_ticks):
		var t = float(i) / float(num_ticks - 1)
		var x = meter_rect.position.x + t * meter_rect.size.x
		
		# Draw tick mark
		canvas.draw_line(
			Vector2(x, meter_rect.position.y),
			Vector2(x, meter_rect.position.y - tick_length),
			text_color, 2.0 * size_ratio
		)
		
		# Draw tick labels
		if show_min_max:
			var value = min_value + t * (max_value - min_value)
			var label = "%.*f" % [decimal_places, value]
			
			canvas.draw_string(_font,
				Vector2(x, meter_rect.position.y - tick_length - 5),
				label,
				HORIZONTAL_ALIGNMENT_CENTER, -1, label_font_size,
				text_color
			)

## Draw vertical meter tick marks
func _draw_vertical_ticks(canvas: Control, meter_rect: Rect2) -> void:
	var size_ratio = meter_rect.size.x / 100.0 # Base tick size on meter width
	var tick_length = clamp(meter_rect.size.x * 0.4, 5, 20)
	
	# Calculate label font size
	var label_font_size = int(meter_rect.size.x * label_font_size_ratio * 2)
	label_font_size = clamp(label_font_size, 8, 16)
	
	for i in range(num_ticks):
		var t = float(i) / float(num_ticks - 1)
		var y = meter_rect.position.y + meter_rect.size.y - t * meter_rect.size.y
		
		# Draw tick mark
		canvas.draw_line(
			Vector2(meter_rect.position.x, y),
			Vector2(meter_rect.position.x - tick_length, y),
			text_color, 2.0 * size_ratio
		)
		
		# Draw tick labels
		if show_min_max:
			var value = min_value + t * (max_value - min_value)
			var label = "%.*f" % [decimal_places, value]
			
			canvas.draw_string(_font,
				Vector2(meter_rect.position.x - tick_length - 5, y),
				label,
				HORIZONTAL_ALIGNMENT_RIGHT, -1, label_font_size,
				text_color
			)

## Draw radial meter tick marks
func _draw_radial_ticks(canvas: Control, center: Vector2, radius: float,
					   start_angle: float, end_angle: float) -> void:
	var size_ratio = radius / 100.0 # Base tick size on radius
	var inner_radius = radius - radius * 0.1
	var outer_radius = radius + radius * 0.1
	
	# Calculate label font size
	var label_font_size = int(radius * label_font_size_ratio)
	label_font_size = clamp(label_font_size, 8, 16)
	
	for i in range(num_ticks):
		var t = float(i) / float(num_ticks - 1)
		var angle = start_angle + t * (end_angle - start_angle)
		var cos_angle = cos(angle)
		var sin_angle = sin(angle)
		
		var inner_point = Vector2(
			center.x + cos_angle * inner_radius,
			center.y + sin_angle * inner_radius
		)
		
		var outer_point = Vector2(
			center.x + cos_angle * outer_radius,
			center.y + sin_angle * outer_radius
		)
		
		# Draw tick mark
		canvas.draw_line(inner_point, outer_point, text_color, 2.0 * size_ratio)
		
		# Draw tick labels
		if show_min_max:
			var value = min_value + t * (max_value - min_value)
			var label = "%.*f" % [decimal_places, value]
			var label_point = Vector2(
				center.x + cos_angle * (outer_radius + radius * 0.15),
				center.y + sin_angle * (outer_radius + radius * 0.15)
			)
			
			canvas.draw_string(_font,
				label_point,
				label,
				HORIZONTAL_ALIGNMENT_CENTER, -1, label_font_size,
				text_color
			)

## Draw horizontal min/max labels
func _draw_horizontal_min_max(canvas: Control, meter_rect: Rect2) -> void:
	# Min/max labels now drawn in the tick marks function
	pass

## Draw vertical min/max labels
func _draw_vertical_min_max(canvas: Control, meter_rect: Rect2) -> void:
	# Min/max labels now drawn in the tick marks function
	pass

## Draw radial min/max labels
func _draw_radial_min_max(canvas: Control, center: Vector2, radius: float,
					   	start_angle: float, end_angle: float) -> void:
	# Min/max labels now drawn in the tick marks function
	pass

## Draw needle for radial gauge
func _draw_radial_needle(canvas: Control, center: Vector2, radius: float,
						start_angle: float, current_angle: float) -> void:
	var needle_length = radius * 0.85
	var cos_angle = cos(current_angle)
	var sin_angle = sin(current_angle)
	
	var needle_point = Vector2(
		center.x + cos_angle * needle_length,
		center.y + sin_angle * needle_length
	)
	
	# Scale needle thickness with radius
	var needle_thickness = clamp(radius * 0.03, 2, 6)
	
	# Draw needle
	canvas.draw_line(center, needle_point, Color(0.1, 0.1, 0.1, 0.8), needle_thickness)
	
	# Draw small circle at the end of the needle
	var tip_radius = clamp(radius * 0.05, 3, 10)
	canvas.draw_circle(needle_point, tip_radius, _get_meter_color((_displayed_value - min_value) / (max_value - min_value)))

## Draw the value text display
func _draw_value_text(canvas: Control, content_rect: Rect2, y_position: float) -> void:
	var value_text = "%.*f" % [decimal_places, _displayed_value]
	if unit:
		value_text += " " + unit
	
	# Calculate font size based on component size
	var font_size = int(content_rect.size.y * value_font_size_ratio)
	font_size = max(12, font_size) # Ensure minimum readable size
	
	# Get text width for proper centering
	var text_width = _font.get_string_size(value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	
	# Position explicitly centered
	var pos = Vector2(
		content_rect.position.x + (content_rect.size.x - text_width) / 2,
		y_position
	)
	
	# Draw with explicit positioning and consistent text color
	canvas.draw_string(_font, pos, value_text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

########################################################
# Animation
########################################################

## Start animation from old value to new value
func _start_animation(from_value: float, to_value: float) -> void:
	# Kill any existing animation
	if _tween and _tween.is_valid():
		_tween.kill()
	
	_displayed_value = from_value
	
	# Create a new tween
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	
	# Tween the displayed value
	_tween.tween_property(self, "_displayed_value", to_value, animation_speed)
	_tween.tween_callback(_on_animation_complete)

## Called when animation completes
func _on_animation_complete() -> void:
	_displayed_value = value
	_request_redraw()

########################################################
# Public API
########################################################

## Set the value and optionally animate the transition
func set_value(new_value: float, animate: bool = true) -> void:
	var old_value = value
	value = clamp(new_value, min_value, max_value)
	
	if animate and animate_value_changes and old_value != value:
		_start_animation(old_value, value)
	else:
		_displayed_value = value
	
	_request_redraw()

## Set the range of the meter
func set_range(new_min: float, new_max: float) -> void:
	min_value = new_min
	max_value = new_max
	value = clamp(value, min_value, max_value)
	_request_redraw()

## Set the thresholds for warning and critical levels
func set_thresholds(new_warning: float, new_critical: float) -> void:
	warning_threshold = new_warning
	critical_threshold = new_critical
	_request_redraw()

## Create a gradient from color points
## Example: create_gradient([0.0, 0.5, 1.0], [Color.BLUE, Color.YELLOW, Color.RED])
func create_gradient(positions: Array, colors: Array) -> void:
	if positions.size() != colors.size() or positions.size() < 2:
		push_error("ValueMonitorMeterUI: Invalid gradient data. Need equal number of positions and colors.")
		return
	
	var gradient = Gradient.new()
	
	# Clear existing points (if any)
	for i in range(gradient.get_point_count()):
		gradient.remove_point(0)
	
	# Add all points
	for i in range(positions.size()):
		gradient.add_point(positions[i], colors[i])
	
	var texture = GradientTexture1D.new()
	texture.gradient = gradient
	color_gradient = texture
