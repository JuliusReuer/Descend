extends Node
var has_seed:bool = false
var seed:int
var collected:Dictionary[String,bool] = {}
var unlocked:Array[String] = []
var inventory:Dictionary[String,int] = {}

func get_seed()->int:
	if has_seed:
		return seed
	has_seed = true
	seed = randi()
	return seed
