extends Item

var description = "A windup key that probably belongs to a clock."
var itemName = "key"

func _ready():
	spritePath = load("res://Sprites/Key_Find.png")
	mapSpritePath = load("res://Sprites/Key_Map.png")
	type = "Key"

func use(player):
	player.key = true

func copy(item):
	itemName = item.itemName
	description = item.description
	spritePath = item.spritePath

func discover():
	pass
