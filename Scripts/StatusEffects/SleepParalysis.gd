extends Resource

class_name SleepParalysis

func inflict(target):
	if target.hasGear() && target.gear.get_child(0).status == Game.status.Paralysis:
		pass
	else:
		target.status = Game.status.Paralysis
