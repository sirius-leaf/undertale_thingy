extends Control


@export var attack_type := 0
@export var attack: PackedScene

var _delay := 1.0


func _process(delta: float) -> void:
	if _delay > 0:
		_delay -= delta
	else:
		var attack_instance: Area2D = attack.instantiate()
		
		match attack_type:
			0:
				attack_instance.position = Vector2(148.0, 14.0 + position.y)
				
			1:
				attack_instance.position = position + Vector2(16.0, 16.0)
				attack_instance.rotation_degrees = rotation_degrees
		
		add_sibling(attack_instance)
		queue_free()
