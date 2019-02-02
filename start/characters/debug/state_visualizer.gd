extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _physics_process(delta):
	text = str(get_parent().state)