extends Item

class_name NightLight

var itemName : String
var description : String

func _ready():
	itemName = "Night Light"
	description = "A sweet duck-shaped night light that keeps the dark away. \nIlluminates surrounding tiles on the map for the rest of the floor."
	spritePath = load("res://Sprites/Light_Find.png")
	mapSpritePath = load("res://Sprites/Light_Map.png")
	
	type = "Map"

func use(player):
	Game.illuminated = true
	if self in player.inv.get_children():
		player.inv.remove_child(self)
	return null

func discover():
	pass

func copy(item):
	itemName = item.itemName
	description = item.description
	spritePath = item.spritePath
