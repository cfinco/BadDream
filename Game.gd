extends Node

var player
var map
var level = 1
var tileTemp
var inMenu = false
var illuminated = false

var types = {
	"None" : 0,
	"Light" : 1,
	"Dark" : 2,
	"Fire" : 3
	}

var status = {
	"None" : 0,
	"Poison" : 1,
	"Confusion" : 2,
	"Paralysis" : 3,
	"Static" : 4,
	"Bleed" : 5,
	"Drowsy" : 6
}

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func generateNewMap():
	var w = map.mapWidth
	var h = map.mapHeight
	map.create_map(w, h)
