class_name DamnBirdController
extends Node2D


const DAMN_ATTACK_WARNING = preload("res://scenes/object_scenes/damn_attack_warning.tscn")

var health := 1500

var _attack_order := 0
var _delay := 0.0
var _battle_start := false
var _warn_pos_y := 0.0
var _attack_duration := 5.0

@onready var soul: SoulController = $"../Soul"
@onready var text_box: NinePatchRect = $"../Ui/MainUi/TextBox"
@onready var main_ui: UiController = $"../Ui/MainUi"


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if soul.attack:
		attack(0, delta)
		
		if _attack_duration > 0:
			_attack_duration -= delta
		else:
			for node in get_tree().get_nodes_in_group("attack_warning"):
				node.queue_free()
			
			_attack_order = 0
			_delay = 0.0
			_battle_start = false
			_warn_pos_y = 0.0
			_attack_duration = 5.0
			main_ui.reset()
			soul.attack = false


func attack(type: int, delta: float) -> void:
	match type:
		0:
			if not _battle_start:
				_delay = 0.5
				_attack_duration = randf_range(4.0, 8.0)
				
				_battle_start = true
			
			match _attack_order:
				0:
					if _delay > 0:
						_delay -= delta
					elif _battle_start:
						_attack_order += 1
				1:
					var attack_warn := DAMN_ATTACK_WARNING.instantiate()
					
					_warn_pos_y = randf_range(0.0, 120.0)
					attack_warn.position.y = _warn_pos_y
					text_box.add_child(attack_warn)
					
					_delay = 1.0
					_attack_order = 0
