extends Sprite2D
## Generatorn på plattformen. Sätt `running` från koden: true = går (8 rutor, 12 fps), false = avstängd.
## Origo ligger mitt på nederkanten, så nodens position är punkten på däcket där generatorn står.
## Exempel i vyn: däckets mitt (200, 128) + (0, -24) = (200, 104).

@export var running_texture: Texture2D   # items/generator_running.png (8 rutor bredvid varandra)
@export var idle_texture: Texture2D      # items/generator_idle.png
@export var fps := 12.0
@export var running := true:
	set(v):
		running = v
		_apply()

const FRAME_SIZE := Vector2(56, 67)
const FRAMES := 8
var _t := 0.0


func _ready() -> void:
	centered = false
	offset = Vector2(-FRAME_SIZE.x / 2.0, -FRAME_SIZE.y)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_apply()


func _process(delta: float) -> void:
	if running:
		_t += delta
		frame = int(_t * fps) % FRAMES


func _apply() -> void:
	if not is_node_ready():
		return
	frame = 0
	hframes = FRAMES if running else 1
	texture = running_texture if running else idle_texture
	_t = 0.0
