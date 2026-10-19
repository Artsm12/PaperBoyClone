extends Node2D

@export var chunk_scene: PackedScene
@export var initial_chunks: int = 3
@export var chunk_height: float = 480.0

var spawn_y: float = 0.0

func _ready() -> void:
	for i in range(initial_chunks):
		spawn_next_chunk()

func spawn_next_chunk() -> void:
	var new_chunk = chunk_scene.instantiate()
	new_chunk.position = Vector2(0, spawn_y)
	new_chunk.chunk_exited_screen.connect(_on_chunk_exited)
	add_child(new_chunk)
	
	spawn_y -= chunk_height

func _on_chunk_exited(chunk: Node2D) -> void:
	var missed = chunk.check_unhandled_subscribers()
	if missed > 0:
		GameManager.register_missed_deliveries(missed)
	
	spawn_next_chunk()
	chunk.queue_free()
