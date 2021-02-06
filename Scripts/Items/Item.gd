extends Position2D

class_name Item

var spritePath
var mapSpritePath
var type

func find():
	$Sprite.texture = spritePath
