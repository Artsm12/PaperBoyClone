class_name Player
extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var base_speed: float
@export var max_speed: float
@export var min_speed: float
@export var acceleration: float
@export var lateral_speed: float
@export var forward_direction: Vector2
@export var newspaper_scene: PackedScene

@export var base_rotation: int

var lateral_direction: Vector2
var current_forward_speed: float

func _ready() -> void:
	current_forward_speed = base_speed
	lateral_direction = Vector2(-forward_direction.y, forward_direction.x).normalized()
	
	animated_sprite.play("moving")

func _process(delta: float) -> void:
	handle_acceleration(delta)
	handle_movement(delta)

func handle_acceleration(delta: float) -> void:
	if Input.is_action_pressed("player_accelerate"):
		current_forward_speed = move_toward(current_forward_speed, max_speed, acceleration * delta)
		animated_sprite.speed_scale = 3
	elif Input.is_action_pressed("player_deccelerate"):
		current_forward_speed = move_toward(current_forward_speed, min_speed, acceleration * delta)
		animated_sprite.speed_scale = 1.5
	else:
		current_forward_speed = move_toward(current_forward_speed, base_speed, acceleration * delta)
		animated_sprite.speed_scale = 2

func handle_movement(delta: float) -> void:
	var velocity_forward = forward_direction * current_forward_speed
	
	var lateral_input: int
	var target_rotation: float = base_rotation
	
	if Input.is_action_pressed("player_right"):
		target_rotation = 0
		lateral_input = 1
	elif Input.is_action_pressed("player_left"):
		target_rotation = -20
		lateral_input = -1
	else:
		lateral_input = 0
	
	animated_sprite.rotation_degrees = lerp(animated_sprite.rotation_degrees, target_rotation, 0.1)
			
	var velocity_lateral = lateral_direction * (lateral_input * lateral_speed)
	var velocity = velocity_forward + velocity_lateral
	position += velocity * delta
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacles"):
		GameEvents.player_crashed.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("obstacles"):
		GameEvents.player_crashed.emit()
		
	
	if Input.is_action_just_pressed("throw_journal"):
		throw_newspaper()

func throw_newspaper() -> void:
	if not newspaper_scene:
		return
		
	var paper = newspaper_scene.instantiate()
	# Posição de origem do lançamento a partir do jogador
	paper.global_position = global_position
	
	# Calcular direção do arremesso (por exemplo, perpendicular ao avanço)
	var throw_velocity = lateral_direction * 300.0 + (forward_direction * current_forward_speed)
	
	if paper.has_method("setup"):
		paper.setup(throw_velocity)
		
	get_parent().add_child(paper)
