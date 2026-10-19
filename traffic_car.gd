extends CharacterBody2D

@export var move_speed: float = 150.0

func _physics_process(delta: float) -> void:
	velocity.y = move_speed
	move_and_slide()
