class_name DungeonData
##Door,Key
var door_key_list: Dictionary[String,String] = {}
##List of all rooms that contain a normal dungeon key
var key_placements: Array[String] = []
##Room,Item_id
var item_placements: Dictionary[String,String] = {}
##Room,Ability_id
var ability_placements: Dictionary[String,String] = {}
##Room,Upgrade_id
var upgrade_placements: Dictionary[String,String] = {}
##Room,Treasure_id
var treasure_placements: Dictionary[String,String] = {}
