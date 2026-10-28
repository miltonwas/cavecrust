extends Node2D

# Strip rows in one strip image (its height).
const STRIP_ROWS := 1280

@onready var cave_material: ShaderMaterial = $Cave.material
@onready var depth_gauge = $UI/DepthGauge
@onready var game_over: CanvasLayer = $GameOver
@onready var camera_2d: Camera2D = $Camera2D


# Which cave to start in: 1 = gold mine, 2 = crystal cave, 3 = magma.
# Change it from code with: cave = 2
@export var cave := 1:
	set(value):
		cave = value
		if is_node_ready():
			_jump_to_cave()

# How fast the platform goes down, in strip rows per second. Negative = up.
@export var speed := 80.0

# The speed where the wheels spin at their normal animation speed.
# Twice as fast down = wheels spin twice as fast. Going up spins them backwards.
@export var wheel_base_speed := 40.0

# How many strip lengths each cave lasts before the transition to the next.
@export var cave_length := 3:
	set(value):
		cave_length = value
		if is_node_ready():
			cave_material.set_shader_parameter("tiles_level1", cave_length)
			cave_material.set_shader_parameter("tiles_level2", cave_length)

# How far down the platform has gone, in strip rows.
var depth := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over.hide()
	cave_length = cave_length
	_jump_to_cave()
	$Player.lives_changed.connect(func(lives): $UI/HBoxContainer/Label.text = " Lives: %d" % lives)
	$Player.player_dead.connect(_on_player_dead)
	$Player.get_node("RemoteTransform2D").remote_path = camera_2d.get_path()
	game_over.button_pressed.connect(_game_over_respawn)
	for wheel in _wheels():
		wheel.play("default")

func _game_over_respawn() -> void:
	get_tree().reload_current_scene()

func _on_player_dead() -> void:
	speed = -300
	game_over.show()
	$Player/RemoteTransform2D.update_position = false
	camera_2d.position = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	depth += speed * delta
	cave_material.set_shader_parameter("depth_rows", depth)
	depth_gauge.progress = depth_gauge.progress_from_depth(depth * 0.5)
	# Spin the wheels as fast as the platform moves.
	for wheel in _wheels():
		wheel.speed_scale = speed / wheel_base_speed


# All the animated wheels on the platform.
func _wheels() -> Array[Node]:
	return $Platform.get_children().filter(func(n): return n is AnimatedSprite2D)


# Moves straight to the start of the chosen cave.
func _jump_to_cave() -> void:
	# Each cave is cave_length strips followed by one transition strip.
	# The view reaches 219 rows above the depth, so start a bit in to hide the previous cave.
	depth = (cave - 1) * (cave_length + 1) * STRIP_ROWS + 220
	cave_material.set_shader_parameter("depth_rows", depth)
