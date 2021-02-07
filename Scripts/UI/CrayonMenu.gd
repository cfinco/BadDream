extends Node2D

onready var buttons = $MenuBackground.get_children()

var buttonIndex = 0
var selectedButton

func _ready():
	selectedButton = buttons[0]

func _process(delta):
	for b in buttons:
		b.color = Color(0.2, 0.2, 0.2)
		selectedButton.color = Color(0.9, 0.8, 0)

func _input(event):
	if event.is_action_pressed("ui_down"):
		if buttonIndex >= buttons.size() - 1:
			buttonIndex = 0
			selectedButton = buttons[buttonIndex]
		else:
			buttonIndex += 1
			selectedButton = buttons[buttonIndex]
	elif event.is_action_pressed("ui_up"):
		if buttonIndex <= 0:
			buttonIndex = buttons.size() - 1
			selectedButton = buttons[buttonIndex]
		else:
			buttonIndex -= 1
			selectedButton = buttons[buttonIndex]
	elif event.is_action_pressed("ui_accept"):
		match buttonIndex:
			0:
				get_parent().markItems()
			1:
				get_parent().markMonsters()
			2:
				get_parent().markExit()
		Game.usingCrayons = false
		Game.inMenu = false
		queue_free()
