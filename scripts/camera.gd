extends Camera2D

@export var zoom_aspect: float = 1.80

func setup_zoom_from_sprite(sprite: Sprite2D) -> void:
	if not sprite or not sprite.texture:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var sprite_size: Vector2 = sprite.texture.get_size() * sprite.scale
	
	var base_zoom: float = viewport_size.x / sprite_size.x
	var final_zoom: float = base_zoom * zoom_aspect
	
	zoom = Vector2(final_zoom, final_zoom)
