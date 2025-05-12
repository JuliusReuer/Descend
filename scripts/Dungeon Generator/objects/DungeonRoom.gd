class_name DungeonRoom

enum DungeonRoomType {
	ROOM,
	KEY_ROOM,
	LOCKED_ROOM,
	START,
	END,
}

var _position: Vector2
var _size: Vector2
var _color: Color
var _connected_rooms: Array[int]
var _room_type: DungeonRoomType


func _init(position: Vector2, size: Vector2, color: Color) -> void:
	_position = position
	_size = size
	_color = color


func move(direction: Vector2):
	_position += direction


func set_color(color: Color):
	_color = color


func set_room_type(type: DungeonRoomType):
	_room_type = type


func add_connection(room_idx: int):
	_connected_rooms.push_back(room_idx)


func draw(renderer: Node2D, debug_render: bool = false):
	var draw_color = Color.GRAY if debug_render else _color
	renderer.draw_rect(Rect2i(_position, _size), draw_color, false, 1)


func is_overlapping(other: DungeonRoom):
	return (
		_position.x < other._position.x + other._size.x
		&& _position.x + _size.x > other._position.x
		&& _position.y + _size.y > other._position.y
		&& _position.y < other._position.y + other._size.y
	)


func get_position() -> Vector2:
	return _position


func get_size() -> Vector2:
	return _size


func get_center() -> Vector2:
	return get_position() + get_size() / 2
