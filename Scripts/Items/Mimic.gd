extends Item

class_name Mimic

onready var battleMenu = preload("res://Scenes/Menus/Battle.tscn")

export var stats : Resource
var itemName : String
var description : String
var monster

func _ready():
	itemName = stats.name
	description = stats.description
	monster = load(stats.monsterPath)
	spritePath = load(stats.spritePath)
	mapSpritePath = load(stats.mapSpritePath)
	type = "Mimic"

func use(tile, player):
	var mon = monster.instance()
	tile.monsters.add_child(mon)
	Game.inMenu = true
	var popUp = battleMenu.instance()
	Game.map.add_child(popUp)

func discover():
	pass

func copy(item):
	itemName = item.itemName
	description = item.description
	spritePath = item.spritePath
