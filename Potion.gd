extends Item

class_name Potion

export var stats : Resource
var itemName : String
var description : String
var healAmount : int

func _ready():
	itemName = stats.name
	description = stats.description
	healAmount = stats.healAmount
	spritePath = load(stats.spritePath)
	mapSpritePath = load(stats.mapSpritePath)
	type = "Potion"

func use(player):
	player.heal(healAmount)
	if self in player.inv.get_children():
		player.inv.remove_child(self)
	return null

func discover():
	healAmount = healAmount + (10 * Game.player.luck)

func copy(item):
	itemName = item.itemName
	description = item.description
	healAmount = item.healAmount
	spritePath = item.spritePath
