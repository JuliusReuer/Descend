extends Node
var path = "res://Screenshots/"


func _process(_delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("screenshot"):
		var img = get_viewport().get_texture().get_image()
		var time = get_date_time_string("YYYY-mm-dd_HH-MM-SS")
		img.save_png(path + time + ".png")


func get_date_time_string(format_string: String) -> String:
	var date_info: Dictionary = Time.get_datetime_dict_from_system()

	var year: int = date_info.get("year", 1970)
	var month: int = date_info.get("month", 1)
	var day: int = date_info.get("day", 1)
	var hour: int = date_info.get("hour", 0)
	var minute: int = date_info.get("minute", 0)
	var second: int = date_info.get("second", 0)
	var dst: int = date_info.get("dst", false)

	# Apply DST adjustment
	if dst:
		hour += 1
		if hour >= 24:
			hour -= 24
			day += 1  # Does not handle month overflow

	# Map placeholders to formatted values
	var replacements = {
		"YYYY": "%04d" % year,
		"mm": "%02d" % month,
		"dd": "%02d" % day,
		"HH": "%02d" % hour,
		"MM": "%02d" % minute,
		"SS": "%02d" % second,
	}

	# Replace each placeholder in the format string
	for key in replacements.keys():
		format_string = format_string.replace(key, replacements[key])

	return format_string
