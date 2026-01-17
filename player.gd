extends CharacterBody3D


#Declare Variables
@onready var head = $Head
@onready var standing_collision_shape = $Standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@export var current_speed = 5.0
const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0
const jump_velocity = 4.5
@export var mouse_sensitivity = 0.26
@export var crouching_depth = -1
@export var crouch_lerp_speed = 5.0
@export var lerp_speed = 10.0
var direction = Vector3.ZERO


#Executes this function in the first tick of the game:

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	
	#Know that there is mouse movement in the game:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-79), deg_to_rad(79), )
		
		
func _physics_process(delta: float) -> void:
	
	#Check for the sprinting buttonaand the crouching button:
	# Crouching is dominant, thus if sprinting and crouching at the same time, the character will crouch no matter what:
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, crouch_lerp_speed*delta) 
		crouching_collision_shape.disabled = false
		standing_collision_shape.disabled = true
	else:
		if Input.is_action_pressed("sprint"):
			head.position.y = lerp(head.position.y, 1.8, crouch_lerp_speed*delta)
			current_speed = sprinting_speed
			crouching_collision_shape.disabled = true
			standing_collision_shape.disabled = false
		else:
			head.position.y = lerp(head.position.y, 1.8, crouch_lerp_speed*delta)
			current_speed = walking_speed
			crouching_collision_shape.disabled = true
			standing_collision_shape.disabled = false
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_velocity * 2

	# Get the input direction and handle the movement/deceleration.

	# Lerp Speed is just the rate at which the lerp function gradually increases a value
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
