extends KinematicBody2D

enum STATES { IDLE, ROAM, RETURN, SPOT, FOLLOW, STAGGER, ATTACK, ATTACK_COOLDOWN, DIE, DEAD}
var state = null

var has_target = false
var target_position = Vector2()

var velocity = Vector2()
const MASS = 1.4

const FOLLOW_RANGE = 500
export(float) var max_follow_speed = 300.0
export(float) var max_roam_speed = 200.0

const ARRIVE_DISTANCE = 3.0
const SLOW_RADIUS = 200.0

var spawn_position = Vector2()


func _ready():
	spawn_position = position
	var target_node = get_tree().get_root().get_node('Game/YSort/Player')
#	var target_node = $'/root/Game/YSort/Player' another implementation of the line above
	if not target_node:
		print('Missing target node %s' % get_path())
		return
	target_node.connect('position_changed', self, '_on_target_position_changed')
	target_node.connect('died', self, '_on_target_died')
	has_target = true
	
	_change_state(IDLE)

func follow(target_position, max_speed):
	var desired_velocity = (target_position - position).normalized() * max_speed
	var steering = (desired_velocity - velocity) / MASS
	velocity += steering
	return position.distance_to(target_position)
	
func arrive_to(target_position, slow_radius, max_speed):
	var desired_velocity = (target_position - position).normalized() * max_speed
	var distance_to_target = position.distance_to(target_position)
	if distance_to_target < slow_radius:
		desired_velocity *= (distance_to_target / slow_radius) * 0.75 + 0.25
		
	var steering = (desired_velocity - velocity) / MASS
	velocity += steering
	return distance_to_target
		
func _change_state(new_state):
	state = new_state


func _physics_process(delta):
	var current_state = state
	match current_state:
		IDLE:
			var distance_to_target = position.distance_to(target_position)
			if distance_to_target < FOLLOW_RANGE:
				if not has_target:
					return
				_change_state(FOLLOW)
		FOLLOW:
			var distance_to_target = follow(target_position, max_follow_speed)
			move_and_slide(velocity)
			if distance_to_target > FOLLOW_RANGE:
				_change_state(RETURN)
		RETURN:
			var distance_to_target = arrive_to(spawn_position, SLOW_RADIUS, max_roam_speed)
			move_and_slide(velocity)
			if distance_to_target < ARRIVE_DISTANCE:
				_change_state(IDLE)
			if position.distance_to(target_position) < FOLLOW_RANGE:
				if not has_target:
					return
				_change_state(FOLLOW)
	
func _on_target_position_changed(new_position):
	target_position = new_position
	
func _on_target_died():
	target_position = Vector2()
	has_target = false
	_change_state(RETURN)
