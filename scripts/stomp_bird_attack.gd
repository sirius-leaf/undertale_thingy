extends Control


func _on_ground_right_body_entered(body: Node2D) -> void:
	if body.is_in_group("soul"):
		if body.receiving_damage:
			body.health -= 3
			body.receiving_damage = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ground_wave":
		queue_free()
