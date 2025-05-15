extends Node2D

@onready var sp0:Sprite2D = $Sprite2D
@onready var sp1:Sprite2D = $Sprite2D2

func expand(rect:Rect2):
	var expand:float = 24 + (max(rect.size.x,rect.size.y)-6)*8
	sp0.position.x = expand
	sp1.position.x = expand*-1

func init(layout:DungeonLayout,id:String,other_id:String,data:DungeonData):
	var cur_room = other_id if layout.to_start_map[other_id] == id else id
	var locked = data.door_key_list.has(cur_room)
	#TODO: ABILITY Lock
	set_frame(1 if locked else 0)

func set_frame(frame:int):
	sp0.frame = frame
	sp1.frame = frame
