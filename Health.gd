extends Control

onready var bar = $HealthBar
onready var barUnder = $HealthBarUnder
onready var barOver = $HealthBarOver
onready var tween = $UpdateTween

var hp = 0 setget set_hp
var max_hp = 0 setget set_max_hp
var index

func start():
	set_max_hp(100)
	set_hp(0)

func set_hp(value):
	hp = value
	bar.value = hp
	barUnder.value = hp

func take_damage(value, barColor):
	barUnder.tint_progress = barColor
	hp = value
	bar.value = hp
	tween.interpolate_property(barUnder, "value", barUnder.value, hp, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	tween.start()

func heal(value):
	barUnder.tint_progress = Color(0, 0.8, 0)
	hp = value
	barUnder.value = hp
	tween.interpolate_property(bar, "value", bar.value, hp, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	tween.start()

func set_max_hp(value):
	max_hp = value
	bar.max_value = max_hp
	barUnder.max_value = max_hp

func _on_Battle_health_changed(health, maxHealth):
	barOver.visible = false
	health = health * 100
	set_max_hp(maxHealth * 100)
	if health < hp:
		if hp - health == 100:
			take_damage(health, Color(0.5, 0.7, 0))
		else:
			take_damage(health, Color(0.8, 0, 0))
	elif health > hp && hp != 0:
		heal(health)
	else:
		set_hp(health)

func _on_Map_health_changed(health, maxHealth):
	health = health * 100
	set_max_hp(maxHealth * 100)
	if health < hp:
		if hp - health == 100:
			take_damage(health, Color(0.5, 0.7, 0))
		else:
			take_damage(health, Color(0.8, 0, 0))
	elif health > hp:
		heal(health)
	else:
		set_hp(health)

func _on_Battle_enemy_health_changed(health, maxHealth, i):
	if i == index:
		health = health * 100
		set_max_hp(maxHealth * 100)
		if health < hp:
			if hp - health == 100:
				take_damage(health, Color(0.5, 0.7, 0))
			else:
				take_damage(health, Color(0.8, 0, 0))
		elif health > hp && hp != 0:
			heal(health)
		else:
			set_hp(health)

func _on_Battle_health_obscured():
	barOver.visible = true
