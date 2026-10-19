extends Node2D

@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

signal chunk_exited_screen(chunk_ref)

func _ready() -> void:
	notifier.screen_exited.connect(_on_screen_exited)

func _on_screen_exited() -> void:
	chunk_exited_screen.emit(self)

func check_unhandled_subscribers() -> int:
	var missed_subscribers = 0
	for child in get_children():
		if child is Area2D and child.is_in_group("targets"):
			if child.is_subscriber and not child.delivered:
				missed_subscribers += 1
	return missed_subscribers
