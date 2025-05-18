extends Label

func _process(delta: float) -> void:
	if Global.player.inventory.has("key"):
		text = str(Global.player.inventory["key"])
	else :
		text = "0"
