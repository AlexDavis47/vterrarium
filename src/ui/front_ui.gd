extends Control
class_name FrontUI

@export var happiness_percentage_label: Label
@export var money_label: Label
@export var time_label: Label

func _ready():
	_update_time()
	_update_money()
	_update_happiness_percentage()

func _process(delta):
	_update_time()
	_update_money()
	_update_happiness_percentage()

# In format: 12:00 AM
func _update_time():
	var datetime = Time.get_datetime_dict_from_system()
	var hour = datetime.hour
	var minute = datetime.minute
	var am_pm = "AM"
	
	if hour >= 12:
		am_pm = "PM"
		if hour > 12:
			hour -= 12
	elif hour == 0:
		hour = 12
	
	var time_string = "%d:%02d %s" % [hour, minute, am_pm]
	time_label.text = time_string

func _update_money():
	money_label.text = Utils.convert_long_float_to_string(SaveManager.save_file.money)

func _update_happiness_percentage():
	var happiness = Utils.get_total_creature_happiness_percentage() * 100
	happiness_percentage_label.text = str(int(round(happiness))) + "%"
