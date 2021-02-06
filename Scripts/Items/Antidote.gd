extends Item

export var stats : Resource
var itemName : String
var description : String
var status
var statusName

func _ready():
	itemName = stats.name
	description = stats.description
	status = stats.status
	statusName = stats.statusName
	spritePath = load(stats.spritePath)
	mapSpritePath = load(stats.mapSpritePath)
	type = "Antidote"

func use(player):
	player.status = Game.status.None
	if self in player.inv.get_children():
		player.inv.remove_child(self)
	if player.temp_hp > 0:
		player.heal(player.temp_hp)
		player.temp_hp = 0
	return null

func discover():
	pass

func copy(item):
	itemName = item.itemName
	description = item.description
	status = item.status
	spritePath = item.spritePath

