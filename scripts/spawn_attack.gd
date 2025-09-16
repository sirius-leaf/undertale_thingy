extends NinePatchRect


var _delay := 1.0

@export var attack: PackedScene


func _process(delta: float) -> void:
	if _delay > 0:
		_delay -= delta
	else:
		var attack_instance: Area2D = attack.instantiate()
		
		attack_instance.position = Vector2(148.0, 14.0 + position.y)
		add_sibling(attack_instance)
		queue_free()
