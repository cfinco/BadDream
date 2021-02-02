extends Node2D

onready var buttons = $Buttons.get_children()

var selectedButton
var buttonIndex = 0

func _ready():
	selectedButton = buttons[0]
	selectedButton.color = Color(0.9, 0.8, 0)

func _input(event):
	if event.is_action_pressed("ui_left"):
		selectedButton.color = Color(0.2, 0.2, 0.2)
		if buttonIndex == 0:
			buttonIndex = buttons.size() - 1 
		else:
			buttonIndex = buttonIndex - 1
		selectedButton = buttons[buttonIndex]
		selectedButton.color = Color(0.9, 0.8, 0)
	elif event.is_action_pressed("ui_right"):
		selectedButton.color = Color(0.2, 0.2, 0.2)
		if buttonIndex == buttons.size() - 1:
			buttonIndex = 0
		else:
			buttonIndex = buttonIndex + 1
		selectedButton = buttons[buttonIndex]
		selectedButton.color = Color(80, 80, 0)
	elif event.is_action_pressed("ui_accept"):
		if buttonIndex == 0:
			Game.inMenu = false
			Game.illuminated = false
			Game.level = 1
			get_tree().reload_current_scene()
		elif buttonIndex == 1:
			get_tree().quit()
