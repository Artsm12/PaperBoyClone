extends Area2D

## Obstáculo com movimentação automática. Serve para carros e também para
## outros obstáculos (pedestre, bola, cachorro...) reaproveitando o script.

## Direção inicial do movimento (global). Com force_horizontal ligado, só o
## sinal do X é usado: positivo = começa indo para a direita.
@export var direction: Vector2 = Vector2.LEFT
## Trava o movimento no eixo X, ignorando o Y de "direction" e rotações dos pais
@export var force_horizontal: bool = true
## Ligue para o carro ficar estacionado: parado onde você colocar, só como obstáculo.
## Desligado (padrão), o carro se movimenta.
@export var parked: bool = false
## Se o CollisionShape2D estiver sem forma, cria um retângulo com esta fração
## do tamanho do sprite (1 = sprite inteiro)
@export_range(0.2, 1.0) var collision_fill: float = 0.8
@export var speed: float = 150.0
## Sorteia a velocidade em ±variation (em %) para os carros não andarem iguais
@export_range(0.0, 0.5) var speed_variation: float = 0.2
## O sprite original está desenhado olhando para a direita?
## (desligue se o carro aparecer andando de ré)
@export var sprite_faces_right: bool = true
## Distância do vai e volta. Se 0, o obstáculo anda em linha reta e some
@export var patrol_distance: float = 400.0
## Distância máxima percorrida (só sem vai e volta) antes de se remover
@export var despawn_distance: float = 3000.0

var _start_position: Vector2
var _travelled: float = 0.0
var _dir_sign: float = 1.0

func _ready() -> void:
	add_to_group("obstacles")

	if force_horizontal:
		direction = Vector2(1.0 if direction.x >= 0.0 else 1.0, 0.0)
	else:
		direction = direction.normalized()

	_start_position = global_position

	if speed_variation > 0.0:
		speed *= randf_range(1.0 - speed_variation, 1.0 + speed_variation)

	_update_facing()

	monitoring = true
	monitorable = true
	area_entered.connect(_on_area_entered)
	_setup_collision.call_deferred()

	if parked:
		set_process(false)

func _process(delta: float) -> void:
	var step: float = speed * delta

	if patrol_distance > 0.0:
		# Vai e volta: anda exatamente até o limite e inverte, sem passar dele
		var previous: float = _travelled
		_travelled = clamp(_travelled + step * _dir_sign, 0.0, patrol_distance)
		global_position += direction * (_travelled - previous)

		if _travelled >= patrol_distance and _dir_sign > 0.0:
			_dir_sign = -1.0
			_update_facing()
		elif _travelled <= 0.0 and _dir_sign < 0.0:
			_dir_sign = 1.0
			_update_facing()
	else:
		global_position += direction * step
		if global_position.distance_to(_start_position) > despawn_distance:
			queue_free()

func _update_facing() -> void:
	# Estacionado: mantém o sprite como está na cena
	if parked:
		return
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return
	# Sem rotação: só espelha o sprite quando o carro muda de sentido
	var facing: Vector2 = direction * _dir_sign

# Garante que o carro "enxerga" a camada de colisão do jogador
func _setup_collision() -> void:
	var has_shape: bool = false
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	for child in get_children():
		if child is CollisionShape2D:
			if child.shape == null and sprite != null and sprite.texture != null:
				var rect := RectangleShape2D.new()
				rect.size = sprite.texture.get_size() * collision_fill
				child.shape = rect
				child.position = sprite.position
			has_shape = has_shape or child.shape != null
		elif child is CollisionPolygon2D:
			has_shape = true
	if not has_shape:
		push_warning("%s não tem forma de colisão: não vai colidir com nada." % name)

	var p := get_tree().get_first_node_in_group("player")
	if p is Area2D:
		if p.collision_layer == 0:
			p.collision_layer = 1
		collision_mask |= p.collision_layer

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.has_method("_take_hit"):
		area._take_hit()
