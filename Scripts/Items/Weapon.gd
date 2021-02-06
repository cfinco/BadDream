extends Item

class_name Weapon

export var stats : Resource
var itemName : String
var description : String
var atkMod : int
var spdMod : int
var weaponType
var typeMult
var aoe
var recoil
var effect

func _ready():
	itemName = stats.name
	description = stats.description
	atkMod = stats.atk_mod
	spdMod = stats.spd_mod
	typeMult = stats.type_mult
	aoe = stats.aoe
	recoil = stats.recoil
	effect = stats.effect
	weaponType = stats.type
	
	spritePath = load(stats.spritePath)
	mapSpritePath = load(stats.mapSpritePath)
	type = "Weapon"

func use(player):
	if player.hasItem() && self in player.inv.get_children():
		if player.hasWeapon():
			var oldWeapon = player.weapon.get_child(0)
			player.weapon.remove_child(oldWeapon)
			player.inv.remove_child(self)
			player.weapon.add_child(self)
			player.inv.add_child(oldWeapon)
			return null
		else:
			player.inv.remove_child(self)
			player.weapon.add_child(self)
			return null
	else:
		if player.hasWeapon():
			var oldWeapon = player.weapon.get_child(0)
			player.weapon.remove_child(oldWeapon)
			player.weapon.add_child(self)
			return oldWeapon
		else:
			player.weapon.add_child(self)
			return null

func discover():
	atkMod = atkMod + (5 * Game.player.luck)

func copy(item):
	itemName = item.itemName
	description = item.description
	atkMod = item.atkMod
	spdMod = item.spdMod
	typeMult = item.typeMult
	weaponType = item.weaponType
	aoe = item.aoe
	recoil = item.recoil
	effect = item.effect
	
	spritePath = item.spritePath
	mapSpritePath = item.mapSpritePath
