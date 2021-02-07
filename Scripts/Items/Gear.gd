extends Item

class_name Gear

export var stats : Resource
var itemName : String
var description : String
var armorValue : float
var gearType : String
var status : int
var statusName : String

func _ready():
	itemName = stats.name
	description = stats.description
	armorValue = stats.armorValue
	gearType = stats.gearType
	status = stats.status
	statusName = stats.statusName
	spritePath = load(stats.spritePath)
	mapSpritePath = load(stats.mapSpritePath)
	type = "Gear"
	

func use(player):
	if player.hasItem() && self in player.inv.get_children():
		if player.hasGear():
			var oldGear = player.gear.get_child(0)
			player.gear.remove_child(oldGear)
			player.inv.remove_child(self)
			player.gear.add_child(self)
			player.inv.add_child(oldGear)
			return null
		else:
			player.inv.remove_child(self)
			player.gear.add_child(self)
			return null
	else:
		if player.hasGear():
			var oldGear = player.gear.get_child(0)
			player.gear.remove_child(oldGear)
			player.gear.add_child(self)
			return oldGear
		else:
			player.gear.add_child(self)
			return null

func discover():
	pass

func copy(item):
	itemName = item.itemName
	description = item.description
	armorValue = item.armorValue
	status = item.status
	statusName = item.statusName
	
	spritePath = item.spritePath
	mapSpritePath = item.mapSpritePath
