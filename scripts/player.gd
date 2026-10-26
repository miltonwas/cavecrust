extends CharacterBody2D
class_name Player

const MAX_SPEED = 350
const ACC = 3000
const JUMP_SPEED = 700
const GRAVITY = 1500

enum{IDLE, WALK, AIR, DEAD}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var state = IDLE
var is_dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		AIR:
			_air_state(delta)
		DEAD:
			_dead_state(delta)

func _update_direction(input_dir: Vector2, delta: float) -> void:
	if input_dir == Vector2.ZERO:
		return
	# Pick the walk animation for whichever direction is pressed the most.
	if abs(input_dir.x) > abs(input_dir.y):
		if input_dir.x < 0:
			anim.play("walk_left")
		else:
			anim.play("walk_right")
	else:
		if input_dir.y < 0:
			anim.play("walk_up")
		else:
			anim.play("walk_down")


func _movement(input_dir: Vector2, delta: float) -> void:
	var target_velocity := input_dir * MAX_SPEED
	velocity = velocity.move_toward(target_velocity, ACC * delta)
	move_and_slide()
	

func _idle_state(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_enter_air_state(true)
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	_movement(input_dir, delta)
	_update_direction(input_dir, delta)
	
	if velocity.length() != 0:
		_enter_walk_state()
	
func _walk_state(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_enter_air_state(true)
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	_movement(input_dir, delta)
	_update_direction(input_dir, delta)
	
	if velocity.length() == 0:
		_enter_idle_state()

func _air_state(delta: float) -> void:
	pass

func _dead_state(delta: float) -> void:
	pass

#-------------ENTER STATE FUNCTIONS--------------
func _enter_idle_state() -> void:
	state = IDLE
	anim.play("idle")

func _enter_walk_state() -> void:
	state = WALK

func _enter_air_state(jumping: bool) -> void:
	state = AIR

func _enter_dead_state(dir: Vector2) -> void:
	if not is_dead:
		state = DEAD
		is_dead = true
