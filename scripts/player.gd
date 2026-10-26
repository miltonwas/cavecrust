extends CharacterBody2D
class_name Player

const MAX_SPEED = 300
const ACC = 3000
const JUMP_SPEED = 700
const GRAVITY = 1500

enum{IDLE, WALK, AIR, PUNCH, DEAD}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var state = IDLE
var is_dead: bool = false
var facing := "down" # "down", "up", "left" or "right"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_play_anim("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		WALK:
			_walk_state(delta)
		AIR:
			_air_state(delta)
		PUNCH:
			_punch_state(delta)
		DEAD:
			_dead_state(delta)

func _update_direction(input_dir: Vector2, delta: float) -> void:
	if input_dir == Vector2.ZERO:
		return
	# Face whichever direction is pressed the most.
	if abs(input_dir.x) > abs(input_dir.y):
		if input_dir.x < 0:
			facing = "left"
		else:
			facing = "right"
	else:
		if input_dir.y < 0:
			facing = "up"
		else:
			facing = "down"
	_play_anim("walk")


# Plays e.g. "walk" or "idle" in the direction the player is facing.
func _play_anim(action: String) -> void:
	anim.play(action + "_" + facing)


func _movement(input_dir: Vector2, delta: float) -> void:
	var target_velocity := input_dir * MAX_SPEED
	velocity = velocity.move_toward(target_velocity, ACC * delta)
	move_and_slide()
	

func _idle_state(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_enter_air_state(true)
	if Input.is_action_just_pressed("punch"):
		_enter_punch_state()
		return
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	_movement(input_dir, delta)
	_update_direction(input_dir, delta)
	
	if velocity.length() != 0:
		_enter_walk_state()
	
func _walk_state(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_enter_air_state(true)
	if Input.is_action_just_pressed("punch"):
		_enter_punch_state()
		return
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	_movement(input_dir, delta)
	_update_direction(input_dir, delta)
	
	if velocity.length() == 0:
		_enter_idle_state()

func _air_state(delta: float) -> void:
	pass

func _punch_state(delta: float) -> void:
	# Keep walking while punching. The punch keeps the direction it started in.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_movement(input_dir, delta)

	# When the punch is done, go back to walking or standing.
	if not anim.is_playing():
		if velocity.length() == 0:
			_enter_idle_state()
		else:
			_enter_walk_state()
			_play_anim("walk")

func _dead_state(delta: float) -> void:
	pass

#-------------ENTER STATE FUNCTIONS--------------
func _enter_idle_state() -> void:
	state = IDLE
	_play_anim("idle")

func _enter_walk_state() -> void:
	state = WALK

func _enter_air_state(jumping: bool) -> void:
	state = AIR

func _enter_punch_state() -> void:
	state = PUNCH
	_play_anim("punch")

func _enter_dead_state(dir: Vector2) -> void:
	if not is_dead:
		state = DEAD
		is_dead = true
