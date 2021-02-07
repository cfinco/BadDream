extends Item

class_name Crayons

var itemName : String
var description : String
onready var crayonMenu = preload("res://Scenes/UI/CrayonMenu.tscn")

func _ready():
	itemName = "Box of Crayons"
	description = "A box of magical crayons! Half of them are missing from the box... \nMarks the location of all monsters, items, or exits on the floor."
	spritePath = load("res://Sprites/Crayon_Find.png")
	mapSpritePath = load("res://Sprites/Crayon_Map.png")
	
	type = "Map"

func use(player):
	Game.usingCrayons = true
	Game.inMenu = true
	Game.map.updateStats()
	var popUp = crayonMenu.instance()
	Game.map.add_child(popUp)
	if self in player.inv.get_children():
		player.inv.remove_child(self)
	return null

func discover():
	pass

func copy(item):
	itemName = item.itemName
	description = item.description
	spritePath = item.spritePath
