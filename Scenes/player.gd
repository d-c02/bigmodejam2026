extends CharacterBody3D

var m_velocity = Vector3.ZERO

@export var m_acceleration = 1.0
@export var m_deceleration = 10.0
@export var m_turnSpeed = 1.0
@export var m_maxHorizontalVel = 10.0
@export var m_turnVelocityScaling = 10.0
@onready var m_mesh = %Mesh

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var forward = -get_global_transform().basis.z
	var back = get_global_transform().basis.z
	#var left = -get_global_transform().basis.x
	#var right = get_global_transform().basis.x
	
	if is_on_floor():
		if (Input.is_action_pressed("accelerate")):
			if (m_velocity.dot(forward) < 0):
				m_velocity += m_deceleration * delta * forward
			else:
				m_velocity += m_acceleration * delta * forward
		elif (Input.is_action_pressed("decelerate")):
			if (m_velocity.dot(back) < 0):
				m_velocity += m_deceleration * delta * back
			else:
				m_velocity += m_acceleration * delta * back
		else:
			if (m_velocity.dot(forward) > 0):
				m_velocity += m_acceleration * delta * back
			elif (m_velocity.dot(back) > 0):
				m_velocity += m_acceleration * delta * forward
		if (Input.is_action_pressed("turn_right")):
			m_velocity = m_velocity.rotated(Vector3.UP, -m_turnSpeed * (m_velocity.length() / m_turnVelocityScaling) * delta)
		if (Input.is_action_pressed("turn_left")):
			m_velocity = m_velocity.rotated(Vector3.UP, m_turnSpeed * (m_velocity.length() / m_turnVelocityScaling) * delta)
	else:
		m_velocity.y += get_gravity().y * delta
	
	var h_vel = Vector3(velocity.x, 0, velocity.z)
	if (h_vel.length() > 0):
		if (h_vel.dot(forward) > 0):
			look_at(self.global_position + h_vel)
		else:
			look_at(self.global_position - h_vel)
	velocity = m_velocity
	
	move_and_slide()
	
func _process(delta: float) -> void:
	pass
	
