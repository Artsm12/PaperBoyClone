extends Area2D

@export var is_subscriber: bool = true
var delivered: bool = false

func _ready() -> void:
	add_to_group("targets")
	update_appearance()

func update_appearance() -> void:
	if is_subscriber:
		$Sprite2D.modulate = Color.DODGER_BLUE
	else:
		$Sprite2D.modulate = Color.DIM_GRAY

func receive_paper() -> void:
	if delivered:
		return
	
	delivered = true
	if is_subscriber:
		$Sprite2D.modulate = Color.GREEN
		GameEvents.delivery_made.emit(100)
	else:
		$Sprite2D.modulate = Color.DARK_RED
		GameEvents.delivery_wrong_house.emit(25)
