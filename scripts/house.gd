extends Node2D

## Casa decorativa de fundo (sem colisão).
## Se "texture" for definida, usa o sprite no lugar do desenho simples.
@export var texture: Texture2D

func _ready() -> void:
	if texture:
		$Sprite2D.texture = texture
		$Sprite2D.show()
		$Placeholder.hide()
