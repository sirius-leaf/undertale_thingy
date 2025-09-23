class_name DamnBirdController
extends Node2D


const DAMN_ATTACK_WARNING = preload("res://scenes/object_scenes/damn_attack_warning.tscn")
const LEG_ATTACK_WARNING = preload("res://scenes/object_scenes/leg_attack_warning.tscn")

var health := 1500

var _attack_order := 0
var _delay := 0.0
var _battle_start := false
var _warn_pos_y := 0.0
var _attack_duration := 5.0
var _attack_started := true
var _attack_type: int

@onready var soul: SoulController = %Soul
@onready var text_box: NinePatchRect = %TextBox
@onready var main_ui: UiController = %MainUi


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if soul.attack:
		if _attack_started:
			_attack_type = randi_range(0, 1)
			_attack_started = false 
		
		#attack(1, delta)
		attack(main_ui.attack_type, delta)
		
		if _attack_duration > 0: _attack_duration -= delta
		else: 
			for node in get_tree().get_nodes_in_group("attack_warning"): node.queue_free()
			for node in get_tree().get_nodes_in_group("attack"): node.queue_free()
			
			_attack_order = 0
			_delay = 0.0
			_battle_start = false
			_warn_pos_y = 0.0
			_attack_duration = 5.0
			main_ui.reset()
			soul.attack = false
	else:
		_attack_started = true


func attack(type: int, delta: float) -> void:
	match type:
		0:
			_start_attack()
			
			match _attack_order:
				0:
					_start_attack_delay(delta)
				1:
					var attack_warn := DAMN_ATTACK_WARNING.instantiate()
					
					_warn_pos_y = randf_range(0.0, 120.0)
					attack_warn.position.y = _warn_pos_y
					text_box.add_child(attack_warn)
					
					_delay = 1.0
					_attack_order = 0
		1:
			_start_attack()
			
			match _attack_order:
				0:
					_start_attack_delay(delta)
				1:
					var attack_warn := LEG_ATTACK_WARNING.instantiate()
					
					attack_warn.position = Vector2(randf_range(30, 150), randf_range(30, 150))
					attack_warn.rotation_degrees = randi_range(0, 3) * 90.0
					text_box.add_child(attack_warn)
					
					_delay = 1.0
					_attack_order = 0


func _start_attack_delay(delta: float) -> void:
	if _delay > 0:
		_delay -= delta
	elif _battle_start:
		_attack_order += 1


func _start_attack() -> void:
	if not _battle_start:
		_delay = 0.5
		_attack_duration = randf_range(4.0, 8.0)
		
		_battle_start = true
