extends Node2D

@onready var sp0: Sprite2D = $Sprite2D
@onready var sp1: Sprite2D = $Sprite2D2
@onready var sp2: Sprite2D = $Sprite2D3
@onready var col:CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	expand(Rect2(0,0,6,7),false)

func expand(rect: Rect2, vertical: bool) -> void:
	var expansion: float = 24 + ((rect.size.x if !vertical else rect.size.y) - 6) * 8
	sp0.position.x = expansion
	sp1.position.x = expansion * -1
	
	var size: Vector2i = Vector2i(16, 16)
	if vertical:
		size.y *= 4
		size.x *= int(rect.size.y) - 6
	else:
		size.y *= 4
		size.x *= int(rect.size.x) - 6
	if min(size.x, size.y) != 0:
		var img: Image = Image.create(size.x, size.y, false, Image.FORMAT_BPTC_RGBF)
		sp2.texture = ImageTexture.create_from_image(img)
	
	var sh:RectangleShape2D = RectangleShape2D.new()
	size = Vector2i(16, 16)
	if vertical:
		size.y *= 4
		size.x *= int(rect.size.y)
	else:
		size.y *= 4
		size.x *= int(rect.size.x)
	sh.set_size(size)
	col.shape = sh

func init(layout: DungeonLayout, id: String, other_id: String, data: DungeonData) -> void:
	var cur_room: String = other_id if layout.to_start_map[other_id] == id else id
	var key_room = data.door_key_list[cur_room]
	var locked: bool = data.key_placements.has(key_room)
	#TODO: ABILITY Lock
	set_frame(1 if locked else 0)
	col.disabled = !locked


func set_frame(frame: int) -> void:
	sp0.frame = frame
	sp1.frame = frame
