extends Node3D

@onready var m_ball = %ball
@onready var m_mesh = %mesh
@onready var m_ground_ray = %mesh/raycast

var m_sphere_offset = Vector3(0, 1.0, 0)
@export var m_acceleration = 50.0
@export var m_steering = 21.0
@export var m_turn_speed = 5.0
@export var m_turn_stop_limit = 0.75

var m_speed_input = 0
var m_rotate_input = 0

func _ready() -> void:
    m_ground_ray.add_exception(m_ball)

func _physics_process(_delta):
    # Keep the car mesh aligned with the sphere
    m_mesh.transform.origin = m_ball.transform.origin - m_sphere_offset
    # Accelerate based on car's forward direction
    m_ball.apply_central_force(-m_mesh.global_transform.basis.z * m_speed_input)

func _process(delta: float) -> void:
    if not m_ground_ray.is_colliding():
        return
    else:
        # Get accelerate/brake input
        m_speed_input = 0
        m_speed_input += Input.get_action_strength("accelerate")
        m_speed_input -= Input.get_action_strength("decelerate")
        m_speed_input *= m_acceleration
        # Get steering input
        m_rotate_input = 0
        m_rotate_input += Input.get_action_strength("turn_left")
        m_rotate_input -= Input.get_action_strength("turn_right")
        m_rotate_input *= deg_to_rad(m_steering)
