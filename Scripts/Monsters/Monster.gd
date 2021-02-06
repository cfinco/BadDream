extends Position2D

var monster_name : String
var monster_class : String
var description : String
var weakness : String
onready var sprite = $Sprite
onready var anchor = $SelectorAnchor

export var effect : Resource
export var stats : Resource
export var children : Resource

var hp : int
var max_hp : int
var atk : int
var spd : int

var level : int
var xp_award : int
var defeated = false
var activated = false
var childFormation
var childChance

var effectChance

var lootDrop

var mapSprite
var battleSprite

func _ready():
	
	level = Game.level
	
	monster_name = stats.name
	description = stats.description
	monster_class = stats.monster_class
	weakness = stats.weakness
	
	max_hp = stats.hp + (20 * (level - 1))
	hp = max_hp
	atk = stats.atk + (5 * (level - 1))
	spd = stats.spd + (10 * (level - 1))
	
	effectChance = stats.effectChance
	
	xp_award = stats.xpAward
	level = 1
	
	if monster_class == "Parent":
		childFormation = children.children
		childChance = children.chance
	
	battleSprite = load(stats.battleSprite)
	mapSprite = load(stats.mapSprite)
	$Sprite.texture = battleSprite

func attack(target, spare):
	target.damage(atk)
	if spare:
		if target.hp <= 0:
			target.hp = 1
	if effect != null && target.status == Game.status.None:
		randomize()
		var roll = randi() % 100
		if roll <= effectChance:
			effect.inflict(target)

func damage(amount : int):
	hp -= amount
	if hp < 0:
		hp = 0

func heal(amount : int):
	hp += amount
	if hp > max_hp:
		hp = max_hp

func copy():
	var clone = self.duplicate()
	clone._ready()
	clone.sprite.texture = sprite.texture
	return clone
