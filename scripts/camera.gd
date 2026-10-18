extends Camera2D

@export var zoom_ratio: float

@export var player: Area2D
@export var forward_direction: Vector2

func _ready() -> void:
	global_position = player.global_position


func _process(delta: float) -> void:
	var forward_speed: float = player.current_forward_speed
	var frame_velocity: Vector2 = forward_direction * forward_speed
	global_position += frame_velocity * delta


func setup_zoom_from_sprite(sprite: Sprite2D) -> void:
	if not sprite or not sprite.texture:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var sprite_size: Vector2 = sprite.texture.get_size() * sprite.scale
	
	var base_zoom: float = viewport_size.x / sprite_size.x
	var final_zoom: float = base_zoom * zoom_ratio
	
	zoom = Vector2(final_zoom, final_zoom)
