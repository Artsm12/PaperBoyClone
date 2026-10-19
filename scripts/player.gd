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

@export_group("Arremesso")
@export var throw_speed: float = 300.0
@export var throw_cooldown: float = 0.35
## Liga se o lado do arremesso sair invertido em relação à tecla
@export var invert_throw_side: bool = true

@export_group("Colisão")
@export var invulnerability_time: float = 1.5
@export_group("Limites da rua")
## Se ligado, o jogador não sai da faixa entre lateral_min e lateral_max
## (coordenada global medida ao longo da direção lateral).
@export var limit_lateral: bool = false
@export var lateral_min: float = 0.0
@export var lateral_max: float = 0.0

var lateral_direction: Vector2
var current_forward_speed: float

var _throw_timer: float = 0.0
var _invulnerable: bool = false

func _ready() -> void:
	add_to_group("player")
	current_forward_speed = base_speed
	lateral_direction = Vector2(-forward_direction.y, forward_direction.x).normalized()

	animated_sprite.play("moving")

	# O player.tscn não tem os sinais conectados pelo editor, então conectamos aqui
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	handle_acceleration(delta)
	handle_movement(delta)
	handle_throw(delta)

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

	if limit_lateral:
		var lateral_pos: float = global_position.dot(lateral_direction)
		var clamped: float = clamp(lateral_pos, lateral_min, lateral_max)
		global_position += lateral_direction * (clamped - lateral_pos)

# ---------------------------------------------------------------- Arremesso

func handle_throw(delta: float) -> void:
	_throw_timer = max(0.0, _throw_timer - delta)
	if _throw_timer > 0.0:
		return

	if Input.is_action_just_pressed("throw_journal"):
		throw_newspaper(1)
	elif InputMap.has_action("throw_journal_left") and Input.is_action_just_pressed("throw_journal_left"):
		throw_newspaper(-1)

# side = 1 arremessa para o lado direito, -1 para o esquerdo
func throw_newspaper(side: int = 1) -> void:
	if not newspaper_scene:
		return

	_throw_timer = throw_cooldown

	var paper = newspaper_scene.instantiate()

	# Lado do arremesso: definido pela tecla (sem mira)
	var s: float = float(side)
	if invert_throw_side:
		s = -s

	# O jornal herda a velocidade do jogador + um impulso lateral
	var throw_velocity: Vector2 = lateral_direction * (throw_speed * s) \
		+ forward_direction * current_forward_speed

	if paper.has_method("setup"):
		paper.setup(throw_velocity)

	get_parent().add_child(paper)
	paper.global_position = global_position

# ----------------------------------------------------------------- Colisões

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacles"):
		_take_hit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("obstacles"):
		_take_hit()

func _take_hit() -> void:
	# Invulnerabilidade curta: evita perder várias vidas no mesmo impacto
	if _invulnerable:
		return
	_invulnerable = true

	GameEvents.player_crashed.emit()

	var blinks: int = max(1, int(invulnerability_time / 0.2))
	var tween := create_tween().set_loops(blinks)
	tween.tween_property(animated_sprite, "modulate:a", 0.3, 0.1)
	tween.tween_property(animated_sprite, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(invulnerability_time).timeout
	_invulnerable = false
	animated_sprite.modulate.a = 1.0
