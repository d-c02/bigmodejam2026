extends RigidBody3D

var sphere_offset = Vector3.DOWN
var acceleration = 35.0
var steering = 19.0
var turn_speed = 4.0
var drift_accel = 10.5
var drift_turn = 5.0

var turn_stop_limit = 0.75
var body_tilt = 35

var speed_input = 0
var turn_input = 0

@onready var car_mesh = $mesh
@onready var body_mesh = $mesh/BDBody
@onready var ground_ray = $mesh/raycast
@onready var right_wheel = $mesh/FWR
@onready var left_wheel = $mesh/FWL

func _ready():
	ground_ray.add_exception(self)
	
func _physics_process(delta):
	car_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		apply_central_force(-car_mesh.global_transform.basis.z * speed_input)
	
func _process(delta):
	if not ground_ray.is_colliding():
		return
	
	var cur_turn_speed = turn_speed
	var cur_accel = acceleration
	
	if (Input.is_action_pressed("drift")):
		cur_turn_speed = drift_turn
		cur_accel = drift_accel
		
	speed_input = Input.get_axis("decelerate", "accelerate") * cur_accel
	turn_input = Input.get_axis("turn_right", "turn_left") * deg_to_rad(steering)
	right_wheel.rotation.y = turn_input
	left_wheel.rotation.y = turn_input
	
	if linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y.normalized(), turn_input)
		
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, cur_turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
		var t = -turn_input * linear_velocity.length() / body_tilt
		body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 5.0 * delta)
		if ground_ray.is_colliding():
			var n = ground_ray.get_collision_normal()
			var xform = align_with_y(car_mesh.global_transform, n)
			car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
#	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
