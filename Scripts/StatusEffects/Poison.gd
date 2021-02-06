extends Resource

class_name Poison

func inflict(target):
	target.status = Game.status.Poison
