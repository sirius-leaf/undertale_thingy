extends Control


const STOMP_BIRD_ATTACK = preload("res://scenes/object_scenes/stomp_bird_attack.tscn")

var soul: SoulController
var text_box: NinePatchRect

var _delay := 0.5
var _attack_sequence := 0
var _spawn_attack := true

@onready var bird_texture: TextureRect = $BirdTexture


func _process(delta: float) -> void:
	bird_texture.flip_h = true if soul.global_position.x - position.x < 0 else false
	bird_texture.position.x = -33.0 if bird_texture.flip_h else -19.0
	
	match _attack_sequence:
		0:
			_start_delay(delta, 1)
		1:
			position.y = lerp(position.y, text_box.global_position.y + 40, 1 - exp(-5.0 * delta))
			_start_delay(delta, 1)
		2:
			position.x = lerp(position.x, soul.global_position.x, 1 - exp(-2.0 * delta))
			_start_delay(delta, 1.5)
			_spawn_attack = true
		3:
			position.y = lerp(position.y, text_box.global_position.y + 180, 1 - exp(-10.0 * delta))
			_start_delay(delta, 1, 1)
			
			if position.y >= text_box.global_position.y + 160.0 and _spawn_attack:
				var stomp_bird_attack = STOMP_BIRD_ATTACK.instantiate()
				
				stomp_bird_attack.position.x = position.x - text_box.global_position.x
				stomp_bird_attack.position.y = 180.0
				text_box.add_child(stomp_bird_attack)
				
				_spawn_attack = false


func _start_delay(delta: float, next_delay: float, override_attack_sequence := -1) -> void:
	if _delay > 0: _delay -= delta
	else:
		_delay = next_delay
		if override_attack_sequence < 0: _attack_sequence += 1
		else: _attack_sequence = override_attack_sequence


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("soul"):
		if body.receiving_damage:
			body.health -= 3
			body.receiving_damage = false
