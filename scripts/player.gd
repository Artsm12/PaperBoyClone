class_name Player
extends Area2D

## Velocidade base de deslocamento contínuo para a frenteadsdas
@export var base_speed: float

## Velocidade máxima ao segurar 'acelerar'
@export var max_speed: float

## Velocidade mínima ao frear
@export var min_speed: float

## Taxa de aceleração/desaceleração da bicicleta
@export var acceleration: float

## Velocidade de deslocamento lateral (perpendicular à rua)
@export var lateral_speed: float

@export var forward_direction: Vector2
var lateral_direction: Vector2
var current_forward_speed: float

func _ready() -> void:
	current_forward_speed = base_speed
	lateral_direction = Vector2(-forward_direction.y, forward_direction.x).normalized()

func _process(delta: float) -> void:
	handle_acceleration(delta)
	handle_movement(delta)

func handle_acceleration(delta: float) -> void:
	if Input.is_action_pressed("player_accelerate"):
		current_forward_speed = move_toward(current_forward_speed, max_speed, acceleration * delta)
	elif Input.is_action_pressed("player_deccelerate"):
		current_forward_speed = move_toward(current_forward_speed, min_speed, acceleration * delta)
	else:
		current_forward_speed = move_toward(current_forward_speed, base_speed, acceleration * delta)

func handle_movement(delta: float) -> void:
	var velocity_forward = forward_direction * current_forward_speed
	
	var lateral_input = Input.get_axis("player_left", "player_right")
	var velocity_lateral = lateral_direction * (lateral_input * lateral_speed)
	
	var velocity = velocity_forward + velocity_lateral
	position += velocity * delta
