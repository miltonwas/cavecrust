extends Node2D

# Which cave image scrolls: 1, 2 or 3. Change it from code with: cave = 2
@export var cave := 2:
	set(value):
		cave = value
		if is_node_ready():
			_show_cave()

# Pixels per second the image moves. (0, -100) = upwards, (100, 0) = right.
@export var speed := Vector2(0, -100)

# Extra pixels the image repeats past its edges, on each side. (0, 300) = taller.
@export var margin := Vector2(0, 300):
	set(value):
		margin = value
		if is_node_ready():
			_show_cave()


# Called when the node enters the scene tree for the first time.efsfsefsef
func _ready() -> void:
	cave = 3
	_show_cave()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var image: Sprite2D = get_node("Cave_%d" % cave)
	# Move the picture inside the image, and wrap around so it loops forever.
	image.region_rect.position -= speed * delta
	image.region_rect.position = image.region_rect.position.posmodv(image.texture.get_size())


# Shows the chosen cave and hides the others.
func _show_cave() -> void:
	for i in [1, 2, 3]:
		get_node("Cave_%d" % i).visible = i == cave
	var image: Sprite2D = get_node("Cave_%d" % cave)
	image.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	image.region_enabled = true
	image.region_rect = Rect2(Vector2.ZERO, image.texture.get_size() + margin * 2)
