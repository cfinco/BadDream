extends Control

onready var bar = $HealthBar
onready var barUnder = $HealthBarUnder
onready var barOver = $HealthBarOver
onready var bleedBar = $BleedBar
onready var tween = $UpdateTween

var hp = 0 setget set_hp
var max_hp = 0 setget set_max_hp
var temp_hp = 0 setget set_temp_hp
var index

func start():
	set_max_hp(100)
	set_hp(0)

func set_hp(value):
	hp = value
	bar.value = hp
	barUnder.value = hp

func set_temp_hp(value):
	temp_hp = value
	bleedBar.value = hp + temp_hp

func take_damage(value, barColor, tempValue):
	barUnder.tint_progress = barColor
	hp = value
	temp_hp = tempValue
	bar.value = hp
	if bleedBar != null:
		bleedBar.value = temp_hp + hp
	tween.interpolate_property(barUnder, "value", barUnder.value, hp, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	tween.start()

func heal(value, tempValue):
	barUnder.tint_progress = Color(0, 0.8, 0)
	temp_hp = tempValue
	hp = value
	barUnder.value = hp
	if bleedBar != null:
		bleedBar.value = temp_hp + hp
	tween.interpolate_property(bar, "value", bar.value, hp, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	tween.start()

func set_max_hp(value):
	max_hp = value
	bar.max_value = max_hp
	bleedBar.max_value = max_hp
	barUnder.max_value = max_hp

func _on_Battle_health_changed(health, maxHealth, tempHealth):
	barOver.visible = false
	health = health * 100
	tempHealth = tempHealth * 100
	set_max_hp(maxHealth * 100)
	if health < hp || tempHealth < temp_hp:
		if hp - health == 100:
			take_damage(health, Color(0.5, 0.7, 0), tempHealth)
		else:
			take_damage(health, Color(0.8, 0, 0), tempHealth)
	elif health > hp && hp != 0:
		heal(health, tempHealth)
	else:
		set_hp(health)
		set_temp_hp(tempHealth)

func _on_Map_health_changed(health, maxHealth, tempHealth):
	health = health * 100
	tempHealth = tempHealth * 100
	set_max_hp(maxHealth * 100)
	if health < hp || tempHealth < temp_hp:
		if hp - health == 100:
			take_damage(health, Color(0.5, 0.7, 0), tempHealth)
		else:
			take_damage(health, Color(0.8, 0, 0), tempHealth)
	elif health > hp:
		heal(health, tempHealth)
	else:
		set_hp(health)
		set_temp_hp(tempHealth)

func _on_Battle_enemy_health_changed(health, maxHealth, i):
	if i == index:
		health = health * 100
		set_max_hp(maxHealth * 100)
		if health < hp:
			if hp - health == 100:
				take_damage(health, Color(0.5, 0.7, 0), 0)
			else:
				take_damage(health, Color(0.8, 0, 0), 0)
		elif health > hp && hp != 0:
			heal(health, 0)
		else:
			set_hp(health)

func _on_Battle_health_obscured():
	barOver.visible = true
