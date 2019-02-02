extends Position2D


func _physics_process(delta):
	rotation = round($'..'.velocity.normalized().angle() / PI * 4.0) / 4.0 * PI
