extends CharacterBody2D
class_name EnemyMini

const MAX_SPEED = 50
const ACC = 1500

# Starts chasing when the player is closer than this (pixels).
@export var sight_range := 400.0
# Stops this close to the player instead of walking into them.
@export var stop_distance := 30.0
# How hard a punch pushes it away.
@export var knockback := 400.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var facing := "down" # "down", "up", "left" or "right"
var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var dir := _chase_direction()
	# move_toward also slows down the knockback from take_hit.
	velocity = velocity.move_toward(dir * MAX_SPEED, ACC * delta)
	move_and_slide()

	if dir == Vector2.ZERO:
		anim.play("idle_" + facing)
		return
	# Face whichever direction it moves the most.
	if abs(dir.x) > abs(dir.y):
		facing = "left" if dir.x < 0 else "right"
	else:
		facing = "up" if dir.y < 0 else "down"
	anim.play("walk_" + facing)

# Which way to walk to reach the player. Zero = stay where you are.
func _chase_direction() -> Vector2:
	if player == null:
		return Vector2.ZERO
	var to_player := player.global_position - global_position
	var distance := to_player.length()
	if distance > sight_range or distance < stop_distance:
		return Vector2.ZERO
	return to_player / distance

# Called by the player when a punch hits this enemy's Area2D.
func take_hit(push_dir: Vector2) -> void:
	velocity = push_dir * knockback
	# Flash red for a moment.
	anim.modulate = Color.RED
	create_tween().tween_property(anim, "modulate", Color.WHITE, 0.2)
