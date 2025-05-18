extends Node2D

@onready var sp0: Sprite2D = $Sprite2D
@onready var sp1: Sprite2D = $Sprite2D2
@onready var sp2: Sprite2D = $Sprite2D3
@onready var col:CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var area:CollisionShape2D = $Area2D/CollisionShape2D
var locked: bool = false
var collider_entered: bool = false
var cur_room: String
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
	
	var sha:RectangleShape2D = RectangleShape2D.new()
	size = Vector2i(16, 16)
	if vertical:
		size.y *= 6
		size.x *= int(rect.size.y)+2
	else:
		size.y *= 6
		size.x *= int(rect.size.x)+2
	sha.set_size(size)
	area.shape = sha

func init(layout: DungeonLayout, id: String, other_id: String, data: DungeonData) -> void:
	cur_room = other_id if layout.to_start_map[other_id] == id else id
	if DungeonCache.unlocked.has(cur_room):
		set_frame(0)
		return
		
	if data.door_key_list.has(cur_room):
		var key_room = data.door_key_list[cur_room]
		locked = data.key_placements.has(key_room)
	#TODO: ABILITY Lock
	set_frame(1 if locked else 0)
	col.disabled = !locked


func set_frame(frame: int) -> void:
	sp0.frame = frame
	sp1.frame = frame


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("unlock") and locked and collider_entered:
		if !Global.player.remove_collectable("key"):
			return
		SignalBus.door_left.emit()
		DungeonCache.unlocked.append(cur_room)
		locked = false
		set_frame(1 if locked else 0)
		col.disabled = !locked


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and locked:
		SignalBus.door_entered.emit()
		collider_entered = true
		print("entered")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player and locked:
		SignalBus.door_left.emit()
		collider_entered = false
