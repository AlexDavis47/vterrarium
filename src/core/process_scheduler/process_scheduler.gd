extends Node
class_name ProcessScheduler

signal tick_second(delta: float)
signal tick_minute(delta: float)
signal tick_hour(delta: float)
signal tick_day(delta: float)

var _time_second: float = 0.0
var _time_minute: float = 0.0
var _time_hour: float = 0.0
var _time_day: float = 0.0

## Randomizes the timer offsets to prevent all schedulers from ticking simultaneously
func randomize_offsets() -> void:
	_time_second = randf()
	_time_minute = randf()
	_time_hour = randf()
	_time_day = randf()

func _physics_process(delta: float) -> void:
	_time_second += delta
	if _time_second >= 1.0:
		_time_second -= 1.0 # Subtract instead of setting to 0 to maintain fractional precision
		tick_second.emit(1.0)
		
		_time_minute += 1.0 / 60.0
		if _time_minute >= 1.0:
			_time_minute -= 1.0
			tick_minute.emit(60.0)
			
			_time_hour += 1.0 / 60.0
			if _time_hour >= 1.0:
				_time_hour -= 1.0
				tick_hour.emit(3600.0)
				
				_time_day += 1.0 / 24.0
				if _time_day >= 1.0:
					_time_day -= 1.0
					tick_day.emit(86400.0)
