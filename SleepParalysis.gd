extends Resource

class_name SleepParalysis

func inflict(target):
	target.status = Game.status.Paralysis
