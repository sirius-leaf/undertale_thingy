extends Area2D


var _delay := 0.5


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if _delay > 0: _delay -= delta
	else: queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("soul"):
		if body.receiving_damage:
			body.health -= 3
			body.receiving_damage = false
