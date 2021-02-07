extends Resource

class_name Drowsy

func inflict(target):
	if target.hasGear() && target.gear.get_child(0).status == Game.status.Drowsy:
		pass
	else:
		target.status = Game.status.Drowsy
