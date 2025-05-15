@tool
extends Window


func _ready() -> void:
	close_requested.connect(try_close)


func try_close():
	hide()
