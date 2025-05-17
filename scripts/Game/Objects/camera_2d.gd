extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	offset.y += Input.get_axis("free_cam_up", "free_cam_down") * 20
	offset.x += Input.get_axis("free_cam_left", "free_cam_right") * 20
	if Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		offset.y = 0
		offset.x = 0
