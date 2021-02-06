extends Resource

class_name Drowsy

func inflict(target):
	target.status = Game.status.Drowsy
