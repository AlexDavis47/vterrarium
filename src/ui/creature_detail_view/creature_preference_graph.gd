extends Control
class_name CreaturePreferenceGraph

## We will use this curve to draw the preference graph
@export var curve: Curve = null:
	get:
		return curve
	set(value):
		curve = value
		_sample_curve()
		queue_redraw()

## The number of samples we will use to draw the graph
@export var graph_resolution: int = 100:
	get:
		return graph_resolution
	set(value):
		graph_resolution = value
		_sample_curve()
		queue_redraw()

## The minimum value of the graph
@export var min_value: float = 0.0:
	get:
		return min_value
	set(value):
		min_value = value
		queue_redraw()

## The maximum value of the graph
@export var max_value: float = 1.0:
	get:
		return max_value
	set(value):
		max_value = value
		queue_redraw()

## The width of the graph lines
@export var graph_line_width: float = 2.0:
	get:
		return graph_line_width
	set(value):
		graph_line_width = value
		queue_redraw()

var _points: PackedVector2Array = []


func _ready() -> void:
	if curve:
		curve.changed.connect(_on_curve_changed)
	_sample_curve()


func _on_curve_changed() -> void:
	_sample_curve()
	queue_redraw()


func _sample_curve() -> void:
	if curve == null:
		_points.clear()
		return

	var points: PackedVector2Array = []
	for i in range(graph_resolution):
		var t: float = float(i) / float(graph_resolution - 1)
		var value: float = curve.sample(t)
		points.append(Vector2(t, value))

	_points = points


func _draw() -> void:
	if curve == null or _points.size() == 0:
		return

	var scaled_points = _scale_points_to_rect()
	_draw_curve_lines(scaled_points)


func _scale_points_to_rect() -> PackedVector2Array:
	var rect_size = get_rect().size
	var scaled_points: PackedVector2Array = []
	
	# Scale the points to fit the control's size
	for i in range(_points.size()):
		var x = _points[i].x * rect_size.x
		var y = rect_size.y - (_points[i].y * rect_size.y) # Invert Y to draw from bottom up
		scaled_points.append(Vector2(x, y))
	
	return scaled_points


func _create_x_axis_labels() -> void:
	pass


func _create_y_axis_labels() -> void:
	pass


func _draw_curve_lines(points: PackedVector2Array) -> void:
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], Color.WHITE, graph_line_width)
