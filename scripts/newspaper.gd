class_name Newspaper
extends Area2D

## Tempo de voo antes de o jornal sumir (alcance ≈ throw_speed * lifetime)
@export var lifetime: float = 1.2
@export var spin_speed: float = 12.0

var velocity: Vector2 = Vector2.ZERO
var _time_left: float = 0.0

# Chamado pelo Player antes de adicionar o jornal na cena
func setup(initial_velocity: Vector2) -> void:
	velocity = initial_velocity

func _ready() -> void:
	_time_left = lifetime
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	# Sem mira: voa em linha reta com a velocidade do arremesso
	global_position += velocity * delta
	rotation += spin_speed * delta

	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("targets") and area.has_method("receive_paper"):
		area.receive_paper()
		queue_free()
	elif area.is_in_group("obstacles"):
		queue_free()
