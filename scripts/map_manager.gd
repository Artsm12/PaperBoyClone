extends Node2D

@export var map_chunk: PackedScene
@export var player: Area2D
@export var camera: Camera2D

@export var initial_chunks: int
@export var spawn_distance_threshold: float

var active_chunks: Array[Node2D] = []
var spawn_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	spawn_next_chunk()
		
	var first_chunk = active_chunks[0]
	var chunk_sprite = first_chunk.get_node("Sprite2D")
	camera.setup_zoom_from_sprite(chunk_sprite)
	
	player.global_position = first_chunk.global_position + Vector2(650, 100)
	
	for i in range(initial_chunks - 1):
		spawn_next_chunk()


func _process(delta: float) -> void:
	var distance_to_spawn = player.global_position.distance_to(spawn_position)

	if distance_to_spawn < spawn_distance_threshold:
		spawn_next_chunk()
		remove_old_chunk()


func spawn_next_chunk() -> void:
	var new_chunk: Node2D = map_chunk.instantiate()
	add_child(new_chunk)
	
	new_chunk.global_position = spawn_position
	active_chunks.append(new_chunk)

	var spawn_marker = new_chunk.get_node("SpawnPoint")
	spawn_position = spawn_marker.global_position


func remove_old_chunk() -> void:
	if active_chunks.size() > initial_chunks + 1:
		var old_chunk = active_chunks.pop_front()
		old_chunk.queue_free()
