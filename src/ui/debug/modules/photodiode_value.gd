extends PanelContainer


@export var curve_visualizer: CurveVisualizerUI

func _ready():
	pass

func _process(delta):
	curve_visualizer.curve = VTHardware._brightness_response_curve
	curve_visualizer.current_value = VTHardware.photodiode_normalized_pre_curve
