extends Node

const START_LIVES: int = 3
const START_SUBSCRIBERS: int = 10

# Quantidade de casas (assinantes) que precisam receber o jornal para vencer
var target_deliveries: int = 5

var score: int = 0
var lives: int = START_LIVES
var deliveries: int = 0
var active_subscribers: int = START_SUBSCRIBERS
var game_finished: bool = false
var won: bool = false

func _ready() -> void:
	GameEvents.delivery_made.connect(_on_delivery_made)
	GameEvents.delivery_wrong_house.connect(_on_delivery_wrong)
	GameEvents.player_crashed.connect(_on_player_crashed)
	reset()

# Chame antes de recarregar a cena para recomeçar a partida
func reset() -> void:
	score = 0
	lives = START_LIVES
	deliveries = 0
	active_subscribers = START_SUBSCRIBERS
	game_finished = false
	won = false
	get_tree().paused = false

	GameEvents.lives_changed.emit(lives)
	GameEvents.score_changed.emit(score)
	GameEvents.deliveries_changed.emit(deliveries, target_deliveries)
	GameEvents.subscriber_status_updated.emit(active_subscribers)

func register_missed_deliveries(count: int) -> void:
	if game_finished:
		return

	active_subscribers = max(0, active_subscribers - count)
	GameEvents.subscriber_status_updated.emit(active_subscribers)

	if active_subscribers <= 0:
		game_over()

func _on_delivery_made(points: int) -> void:
	if game_finished:
		return

	score += points
	deliveries += 1
	GameEvents.score_changed.emit(score)
	GameEvents.deliveries_changed.emit(deliveries, target_deliveries)

	if deliveries >= target_deliveries:
		win()

func _on_delivery_wrong(penalty: int) -> void:
	if game_finished:
		return

	score = max(0, score - penalty)
	GameEvents.score_changed.emit(score)

func _on_player_crashed() -> void:
	if game_finished:
		return

	lives -= 1
	GameEvents.lives_changed.emit(lives)

	if lives <= 0:
		game_over()

func win() -> void:
	game_finished = true
	won = true
	get_tree().paused = true
	print("Vitória! Pontuação final: ", score)
	GameEvents.game_won.emit()

func game_over() -> void:
	game_finished = true
	won = false
	get_tree().paused = true
	print("Game Over! Pontuação final: ", score)
	GameEvents.game_lost.emit()
