extends Node

var score: int = 0
var lives: int = 3
var active_subscribers: int = 10

func _ready() -> void:
	GameEvents.delivery_made.connect(_on_delivery_made)
	GameEvents.delivery_wrong_house.connect(_on_delivery_wrong)
	GameEvents.player_crashed.connect(_on_player_crashed)
	GameEvents.player_crashed.emit()

func register_missed_deliveries(count: int) -> void:
	active_subscribers = max(0, active_subscribers - count)
	GameEvents.subscriber_status_updated.emit(active_subscribers)
	
	if active_subscribers <= 0:
		game_over()

func _on_delivery_made(points: int) -> void:
	score += points

func _on_delivery_wrong(penalty: int) -> void:
	score = max(0, score - penalty)

func _on_player_crashed() -> void:
	lives -= 1
	if lives <= 0:
		game_over()

func game_over() -> void:
	print("Game Over! Pontuação final:", score)
