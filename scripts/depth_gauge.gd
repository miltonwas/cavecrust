extends Control

const TUBE_POS := Vector2(21, 9)       # top left of the fill area inside the textures
const TUBE_HEIGHT := 210.0             # three areas of 70 px
const MARKER_X := 35.0
const MARKER_HALF := 8.0

@export_range(0.0, 1.0, 0.001) var progress: float = 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		_apply()

## Optional: area boundaries in world units of depth, used by progress_from_depth().
## Defaults match the shader with tiles_level1 = 3 and tiles_level2 = 3 (640 world units per strip).
@export var area_ends: PackedFloat32Array = PackedFloat32Array([2240.0, 4800.0, 7360.0])


func _ready() -> void:
	_apply()


func _apply() -> void:
	if not is_node_ready():
		return
	var bar: TextureProgressBar = $Bar
	bar.value = progress
	var fill_px := roundf(progress * TUBE_HEIGHT)
	var head: TextureRect = get_node_or_null("Head")
	if head:
		head.visible = fill_px > 0.0
		head.position = Vector2(TUBE_POS.x, TUBE_POS.y + fill_px - 1.0)
	var marker: TextureRect = get_node_or_null("Marker")
	if marker:
		marker.position = Vector2(MARKER_X, TUBE_POS.y + fill_px - MARKER_HALF)


## Maps a depth to the gauge so that every area fills exactly one third, whatever its length.
func progress_from_depth(depth: float) -> float:
	var start := 0.0
	for i in area_ends.size():
		var end := area_ends[i]
		if depth < end:
			return (i + clampf((depth - start) / (end - start), 0.0, 1.0)) / area_ends.size()
		start = end
	return 1.0
