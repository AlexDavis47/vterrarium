extends PanelContainer

@export var value_monitor_meter: ValueMonitorMeterUI

func _process(delta):
	value_monitor_meter.set_value(Utils.celsius_to_fahrenheit(VTHardware.temperature))
