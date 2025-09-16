extends Area2D


const SPEED = 700.0

@onready var damn_sfx: AudioStreamPlayer2D = $DamnSfx


func _physics_process(delta: float) -> void:
	global_position.x -= SPEED * delta


func _on_damn_sfx_finished() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("soul"):
		if body.receiving_damage:
			body.health -= 1
			body.receiving_damage = false
