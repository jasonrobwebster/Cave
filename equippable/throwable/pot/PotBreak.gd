extends AudioStreamPlayer


func _ready():
	play()
	yield(self, "finished")
	owner.queue_free()
