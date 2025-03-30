@tool
extends Control
class_name CurveVisualizerUI

########################################################
# Exports
########################################################

@export_group("Core")
## Where the curve is drawn
@export var curve_canvas: Control:
	set(value):
		if curve_canvas:
			# Disconnect from previous canvas if it exists
			if curve_canvas.is_connected("draw", _on_canvas_draw):
				curve_canvas.disconnect("draw", _on_canvas_draw)
		
		curve_canvas = value
		
		if curve_canvas:
			# Connect to the new canvas's draw signal
			if not curve_canvas.is_connected("draw", _on_canvas_draw):
				curve_canvas.connect("draw", _on_canvas_draw)
			
			# Make sure the canvas has a higher z-index
			curve_canvas.z_index = 1

## The curve that is being visualized
@export var curve: Curve:
	set(value):
		curve = value
		if curve:
			curve.changed.connect(_on_curve_changed)
		_sample_curve()
		_request_redraw()

@export_group("Display")
## The number of samples to use when drawing the curve
@export_range(10, 500, 1) var resolution: int = 100:
	set(value):
		resolution = value
		_sample_curve()
		_request_redraw()

## The width of the curve line
@export_range(1.0, 10.0, 0.5) var line_width: float = 2.0:
	set(value):
		line_width = value
		_request_redraw()

## The color of the curve line
@export var curve_color: Color = Color.BLACK:
	set(value):
		curve_color = value
		_request_redraw()

## Background color for the graph area (transparent by default)
@export var background_color: Color = Color(0.1, 0.1, 0.1, 0.2):
	set(value):
		background_color = value
		_request_redraw()

## Padding around the graph (in pixels)
@export var padding: Vector2 = Vector2(40, 30):
	set(value):
		padding = value
		_request_redraw()

@export_group("Range")
## The minimum X value to display
@export var min_x: float = 0.0:
	set(value):
		min_x = value
		_sample_curve()
		_request_redraw()

## The maximum X value to display
@export var max_x: float = 1.0:
	set(value):
		max_x = value
		_sample_curve()
		_request_redraw()

## The minimum Y value to display
@export var min_y: float = 0.0:
	set(value):
		min_y = value
		_request_redraw()

## The maximum Y value to display
@export var max_y: float = 1.0:
	set(value):
		max_y = value
		_request_redraw()

@export_group("Grid & Axes")
## Show grid lines
@export var show_grid: bool = true:
	set(value):
		show_grid = value
		_request_redraw()

## Number of grid lines (both horizontal and vertical)
@export_range(2, 20, 1) var grid_lines: int = 4:
	set(value):
		grid_lines = value
		_request_redraw()

## The color of the grid lines
@export var grid_color: Color = Color(0.5, 0.5, 0.5, 0.5):
	set(value):
		grid_color = value
		_request_redraw()

## The color of the axes
@export var axes_color: Color = Color(1.0, 1.0, 1.0, 0.8):
	set(value):
		axes_color = value
		_request_redraw()

@export_group("Marker")
## Current value to mark on the graph
@export_range(0.0, 1.0, 0.01) var current_value: float = 0.5:
	set(value):
		current_value = clamp(value, min_x, max_x)
		_request_redraw()

## Show marker at current value on the graph
@export var show_marker: bool = true:
	set(value):
		show_marker = value
		_request_redraw()

## Marker dot color 
@export var marker_color: Color = Color(1.0, 0.3, 0.3, 1.0):
	set(value):
		marker_color = value
		_request_redraw()

## Marker dot size
@export_range(2.0, 20.0, 0.5) var marker_size: float = 8.0:
	set(value):
		marker_size = value
		_request_redraw()

## Show value labels for the marker
@export var show_marker_labels: bool = true:
	set(value):
		show_marker_labels = value
		_request_redraw()

@export_group("Labels")
## Show axis labels
@export var show_labels: bool = true:
	set(value):
		show_labels = value
		_request_redraw()

## Label color for axis and value labels
@export var label_color: Color = Color(0.9, 0.9, 0.9, 1.0):
	set(value):
		label_color = value
		_request_redraw()

## X-axis label text (empty for none)
@export var x_axis_label: String = "":
	set(value):
		x_axis_label = value
		_request_redraw()

## Y-axis label text (empty for none)
@export var y_axis_label: String = "":
	set(value):
		y_axis_label = value
		_request_redraw()

## Font size for axis labels
@export_range(8, 24, 1) var axis_label_font_size: int = 14:
	set(value):
		axis_label_font_size = value
		_request_redraw()

########################################################
# Private Variables
########################################################

## Sampled points from the curve
var _points: PackedVector2Array = []

## Font for labels
var _font: Font

########################################################
# Initialization
########################################################

func _ready() -> void:
	# Initialize font for labels
	_font = ThemeDB.fallback_font
	
	if curve:
		curve.changed.connect(_on_curve_changed)
	
	# Setup canvas if available
	if curve_canvas:
		# Set up the canvas to handle drawing
		if not curve_canvas.is_connected("draw", _on_canvas_draw):
			curve_canvas.connect("draw", _on_canvas_draw)
		
		# Set z-index to ensure it draws above background elements
		curve_canvas.z_index = 1
		
		# Force update to ensure transparent background is applied correctly
		curve_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_sample_curve()

func _process(delta: float) -> void:
	# When in the editor, make sure we redraw on resize
	if Engine.is_editor_hint():
		_request_redraw()

########################################################
# Drawing
########################################################

## Callback for when the canvas needs to be drawn
func _on_canvas_draw() -> void:
	if curve_canvas == null:
		return
	
	_draw_graph(curve_canvas)

## Request a redraw of the graph canvas
func _request_redraw() -> void:
	if curve_canvas:
		curve_canvas.queue_redraw()
	else:
		queue_redraw()

## Main drawing function - draws to the specified canvas
func _draw_graph(canvas: Control) -> void:
	# Get the drawing area size
	var draw_rect = Rect2(padding, canvas.get_size() - padding * 2)
	
	# Draw background if specified
	if background_color.a > 0:
		canvas.draw_rect(draw_rect, background_color)
	
	# Draw grid
	if show_grid:
		_draw_grid(canvas, draw_rect)
	
	# Draw axes
	_draw_axes(canvas, draw_rect)
	
	# Draw curve
	if _points.size() > 1:
		_draw_curve(canvas, draw_rect)
	
	# Draw marker
	if show_marker and curve:
		_draw_marker(canvas, draw_rect)
	
	# Draw labels
	if show_labels:
		_draw_labels(canvas, draw_rect)
	
	# Draw axis labels
	_draw_axis_labels(canvas, draw_rect)

## Draws the background grid
func _draw_grid(canvas: Control, draw_rect: Rect2) -> void:
	var spacing_x = draw_rect.size.x / grid_lines
	var spacing_y = draw_rect.size.y / grid_lines
	
	# Draw vertical grid lines
	for i in range(grid_lines + 1):
		var x = draw_rect.position.x + spacing_x * i
		canvas.draw_line(Vector2(x, draw_rect.position.y),
				  Vector2(x, draw_rect.position.y + draw_rect.size.y),
				  grid_color, 1.0)
	
	# Draw horizontal grid lines
	for i in range(grid_lines + 1):
		var y = draw_rect.position.y + spacing_y * i
		canvas.draw_line(Vector2(draw_rect.position.x, y),
				  Vector2(draw_rect.position.x + draw_rect.size.x, y),
				  grid_color, 1.0)

## Draws the X and Y axes
func _draw_axes(canvas: Control, draw_rect: Rect2) -> void:
	# X axis
	canvas.draw_line(Vector2(draw_rect.position.x, draw_rect.position.y + draw_rect.size.y),
			  Vector2(draw_rect.position.x + draw_rect.size.x, draw_rect.position.y + draw_rect.size.y),
			  axes_color, 2.0)
	
	# Y axis
	canvas.draw_line(Vector2(draw_rect.position.x, draw_rect.position.y),
			  Vector2(draw_rect.position.x, draw_rect.position.y + draw_rect.size.y),
			  axes_color, 2.0)

## Draws the X and Y axis labels
func _draw_axis_labels(canvas: Control, draw_rect: Rect2) -> void:
	# Draw X-axis label if set
	if x_axis_label != "":
		# Position the label at the center bottom of the graph
		var x_pos = draw_rect.position.x + draw_rect.size.x / 2
		var y_pos = draw_rect.position.y + draw_rect.size.y + padding.y - 5
		
		canvas.draw_string(_font,
			Vector2(x_pos - x_axis_label.length() * 3, y_pos),
			x_axis_label,
			HORIZONTAL_ALIGNMENT_CENTER, -1, axis_label_font_size,
			label_color
		)
	
	# Draw Y-axis label if set
	if y_axis_label != "":
		# Position the label at the left center of the graph, rotated 90 degrees
		var x_pos = draw_rect.position.x - padding.x / 2
		var y_pos = draw_rect.position.y + draw_rect.size.y / 2
		
		# To create a vertical label, we'll use a transform
		var transform = Transform2D()
		transform = transform.rotated(-PI / 2) # Rotate 90 degrees counter-clockwise
		transform.origin = Vector2(x_pos, y_pos)
		
		# Set the transform and draw the string
		canvas.draw_set_transform_matrix(transform)
		canvas.draw_string(_font,
			Vector2(0, 0), # We're using the transform for position
			y_axis_label,
			HORIZONTAL_ALIGNMENT_CENTER, -1, axis_label_font_size,
			label_color
		)
		
		# Reset the transform to identity
		canvas.draw_set_transform_matrix(Transform2D.IDENTITY)

## Draws the curve
func _draw_curve(canvas: Control, draw_rect: Rect2) -> void:
	var scaled_points = _scale_points_to_rect(draw_rect)
	
	# Draw curve using line segments
	for i in range(scaled_points.size() - 1):
		canvas.draw_line(scaled_points[i], scaled_points[i + 1], curve_color, line_width)

## Draws a marker dot at the current value
func _draw_marker(canvas: Control, draw_rect: Rect2) -> void:
	# Get the y value from the curve at the current x value
	var y_value = curve.sample_baked(current_value)
	
	# Create a point
	var point = Vector2(current_value, y_value)
	
	# Scale it to the draw rect
	var normalized_x = (point.x - min_x) / (max_x - min_x)
	var normalized_y = (point.y - min_y) / (max_y - min_y)
	
	# Calculate position
	var x = draw_rect.position.x + normalized_x * draw_rect.size.x
	var y = draw_rect.position.y + draw_rect.size.y - (normalized_y * draw_rect.size.y)
	
	# Draw the marker dot
	canvas.draw_circle(Vector2(x, y), marker_size, marker_color)
	
	# Draw vertical guide line
	canvas.draw_line(
		Vector2(x, draw_rect.position.y),
		Vector2(x, draw_rect.position.y + draw_rect.size.y),
		marker_color.darkened(0.3), 1.0, true
	)
	
	# Draw horizontal guide line
	canvas.draw_line(
		Vector2(draw_rect.position.x, y),
		Vector2(draw_rect.position.x + draw_rect.size.x, y),
		marker_color.darkened(0.3), 1.0, true
	)
	
	# Draw value labels if enabled
	if show_marker_labels:
		var font_size = 12
		
		# X value
		var x_label = "%.2f" % current_value
		canvas.draw_string(_font,
			Vector2(x - x_label.length() * 3, draw_rect.position.y + draw_rect.size.y + 25),
			x_label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size,
			marker_color
		)
		
		# Y value
		var y_label = "%.2f" % y_value
		canvas.draw_string(_font,
			Vector2(draw_rect.position.x - 30, y + 5),
			y_label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size,
			marker_color
		)

## Draws the axis labels
func _draw_labels(canvas: Control, draw_rect: Rect2) -> void:
	var font_size = 12
	var label_offset = Vector2(5, 15)
	
	# X-axis labels
	for i in range(grid_lines + 1):
		var t = float(i) / float(grid_lines)
		var value = min_x + t * (max_x - min_x)
		var x = draw_rect.position.x + t * draw_rect.size.x
		var pos = Vector2(x, draw_rect.position.y + draw_rect.size.y + label_offset.y)
		
		var label = "%.1f" % value
		canvas.draw_string(_font, pos - Vector2(label.length() * 3, 0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, label_color)
	
	# Y-axis labels
	for i in range(grid_lines + 1):
		var t = float(i) / float(grid_lines)
		var value = max_y - t * (max_y - min_y) # Invert for Y-axis
		var y = draw_rect.position.y + t * draw_rect.size.y
		var pos = Vector2(draw_rect.position.x - label_offset.x, y + 5)
		
		var label = "%.1f" % value
		canvas.draw_string(_font, pos - Vector2(label.length() * 7, 0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, label_color)

########################################################
# Helper Methods
########################################################

## Samples the curve at the current resolution
func _sample_curve() -> void:
	_points.clear()
	
	if curve == null:
		return
	
	for i in range(resolution):
		var t = min_x + (float(i) / float(resolution - 1)) * (max_x - min_x)
		var value = curve.sample_baked(t)
		_points.append(Vector2(t, value))

## Scales the sampled points to fit the drawing rectangle
func _scale_points_to_rect(rect: Rect2) -> PackedVector2Array:
	var scaled_points: PackedVector2Array = []
	
	for point in _points:
		# Normalize point coordinates to [0, 1] range
		var normalized_x = (point.x - min_x) / (max_x - min_x)
		var normalized_y = (point.y - min_y) / (max_y - min_y)
		
		# Scale to rect (invert Y to draw from bottom up)
		var x = rect.position.x + normalized_x * rect.size.x
		var y = rect.position.y + rect.size.y - (normalized_y * rect.size.y)
		
		scaled_points.append(Vector2(x, y))
	
	return scaled_points

## Called when the curve resource is modified
func _on_curve_changed() -> void:
	_sample_curve()
	_request_redraw()

## Override the _draw method to handle the case when curve_canvas is not set
func _draw() -> void:
	if curve_canvas == null:
		# If no canvas is set, draw directly on this control
		_draw_graph(self)
