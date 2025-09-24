class_name UiController
extends Control


enum Action {
	NONE, FIGHT, ACT, ITEM, MERCY, FIGHT_START, ACT_SELECT, DISPLAY_ACT, SELECT_ITEM, ENEMY_TURN
}

const ATTACK_SPEED = 300.0
const DAMN_BIRD_DIALOGUE = preload("res://dialogue/damn_bird_dialogue.dialogue")

var attack_type: int

var _selected_action: Action
var _attack_start := true
var _accept_input := false
var _tween_start := true
var _dialogue_finished := false
var _enemy_dialogue_finished := false
var _fight_ready := false
var _empty_item := false
var _select_attack_type := true
var _delay := 0.0
var _last_selected_act := 0
var _last_selected_main_act := 0
var _buttons: Array[Button]
var _act_buttons: Array[Button]
var _item_select_buttons: Array[Button]

@onready var target: Control = $TextBox/Target
@onready var soul: SoulController = $"../../Soul"
@onready var attack_point: Control = $TextBox/AttackAccuracy/AttackPoint
@onready var damn_bird: DamnBirdController = %DamnBird
@onready var damn_bird_health_bar: ProgressBar = $TextBox/Target/DamnBirdSelect/DamnBirdHealthBar
@onready var damn_bird_health_bar_2: ProgressBar = %DamnBird/DamnBirdHealthBar2
@onready var info_text: Control = $TextBox/InfoText
@onready var health_bar: ProgressBar = $HealthInfo/HealthBar
@onready var health_label: Label = $HealthInfo/HealthLabel
@onready var text_box: NinePatchRect = $TextBox


func _ready() -> void:
	info_text.visible = true
	damn_bird_health_bar.value = damn_bird.health
	damn_bird_health_bar_2.value = damn_bird.health
	health_bar.value = soul.health
	attack_point.position.x = 12.0
	
	_update_soul_health_bar()
	
	for node in $ActionButtons.get_children(): _buttons.append(node)
	for node in $TextBox/ActSelect.get_children(): _act_buttons.append(node)
	for node in $TextBox/ItemSelect.get_children(): if node is Button: 
		_item_select_buttons.append(node)
	
	%DamnBird/DialogueBaloon/NinePatchRect/DialogueLabel.finished_typing.\
			connect(_on_enemy_dialogue_finished)
	
	$ActionButtons/FightButton.grab_focus()


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_R): get_tree().reload_current_scene()
	elif Input.is_key_pressed(KEY_ESCAPE): get_tree().quit()
	
	text_box.position = Vector2(320.0 - text_box.size.x / 2.0, 480.0 - text_box.size.y - 87.0)
	
	match _selected_action:
		Action.FIGHT:
			_back_to_main_act($ActionButtons/FightButton)
		Action.FIGHT_START:
			_attack(delta)
			_attack_end(delta)
		Action.ACT:
			_back_to_main_act($ActionButtons/ActButton)
		Action.ACT_SELECT:
			for item in _act_buttons:
				if item.has_focus():
					soul.global_position = item.global_position + Vector2(-16.0, 21.0)
					_last_selected_act = _act_buttons.find(item)
					break
			
			if Input.is_action_just_pressed("ui_cancel"):
				target.visible = true
				$TextBox/ActSelect.visible = false
				_selected_action = Action.ACT
				$TextBox/Target/DamnBirdSelect.grab_focus()
				_act_buttons[_last_selected_act].release_focus()
				soul.global_position = $TextBox/Target/DamnBirdSelect.global_position \
						+ Vector2(-16.0, 21.0)
		Action.DISPLAY_ACT:
			if Input.is_action_just_pressed("ui_accept") and _dialogue_finished:
				_selected_action = Action.ENEMY_TURN
				$TextBox/ActText.visible = false
				_attack_type_select(Action.ACT)
		Action.ITEM:
			for item in _item_select_buttons:
				if item.has_focus():
					soul.global_position = item.global_position + Vector2(-16.0, 21.0)
					$TextBox/ItemSelect/ItemInfo.text = soul.items[_item_select_buttons.find(item)][2]
					break
			
			_back_to_main_act($ActionButtons/ItemButton)
		Action.ENEMY_TURN:
			_update_soul_health_bar()
			
			if Input.is_action_just_pressed("ui_accept") and _enemy_dialogue_finished and \
					_fight_ready:
				soul.visible = true
				soul.attack = true
				%DamnBird/DialogueBaloon.visible = false
		Action.NONE:
			target.visible = false
			soul.visible = true
			$TextBox/Target/DamnBirdSelect/DamnBirdHealthBar.visible = true
			
			for item in _buttons:
				if item.has_focus():
					soul.global_position = item.global_position + Vector2(16.0, 22.0)
					break


func reset() -> void:
	var tween_size := create_tween()
	var tween_size_y := create_tween()
	#var tween_pos := create_tween()
	
	tween_size.tween_property($TextBox, "size:x", 600.0, 0.5)
	tween_size_y.tween_property($TextBox, "size:y", 148.0, 0.5)
	#tween_pos.tween_property($TextBox, "position:x", 20.0, 0.5)
	tween_size.finished.connect(_on_tween_finished_reset)
	$TextBox/AttackAccuracy/AttackAccuracyTexture.modulate.a = 1.0 
	
	soul.visible = false


func _update_soul_health_bar() -> void:
	health_bar.value = soul.health
	health_label.text = str(soul.health) + " / 30"


func _use_item(index: int) -> void:
	soul.health = min(30, soul.health + soul.items[index][1])
	_act_button_dialogue(soul.items[index][3])
	soul.items.pop_at(index)
	
	if soul.items.is_empty():
		var item_button: Button = $ActionButtons/ItemButton
		_empty_item = true
		item_button.set_focus_mode(Control.FOCUS_NONE)
		item_button.disabled = true
	
	_update_soul_health_bar()


func _attack(delta: float) -> void:
	if attack_point.position.x < 588.0:
		if Input.is_action_just_released("ui_accept") and not _accept_input:
			_accept_input = true
		
		if _attack_start:
			attack_point.position.x += ATTACK_SPEED * delta
		
		if Input.is_action_just_pressed("ui_accept") and _accept_input and _attack_start:
			damn_bird.health -= round((300 - abs(attack_point.position.x - 300)) / 300
					* soul.POWER)
			damn_bird_health_bar.value = damn_bird.health
			damn_bird_health_bar_2.value = damn_bird.health
			damn_bird_health_bar_2.visible = true
					
			$TextBox/AttackAccuracy/AttackPoint/Sprite/AnimationPlayer.play("attack")
			print(round((300 - abs(attack_point.position.x - 300)) / 300 * soul.POWER))
			
			_delay = 1.5
			_attack_start = false
	elif _attack_start:
		_delay = 1.5
		
		#damn_bird_health_bar_2.visible = true
		$TextBox/AttackAccuracy/AttackPoint/Sprite/AnimationPlayer.play("attack")
		
		_attack_start = false


func _attack_end(delta: float) -> void:
	if _delay > 0:
		_delay -= delta
	elif not _attack_start:
		attack_point.visible = false
		damn_bird_health_bar_2.visible = false
	
		_attack_type_select(Action.FIGHT)


func _attack_type_select(action: Action, override_attack_type := -1) -> void:
	var box_size: Vector2
	if _select_attack_type:
		if override_attack_type < 0: attack_type = randi_range(0, 1)
		else: attack_type = override_attack_type
		_select_attack_type = false
	
	match attack_type:
		0: box_size = Vector2(148.0, 148.0)
		1: box_size = Vector2(180.0, 180.0)
		2: box_size = Vector2(270.0, 180.0)
	
	_fight_transition_tween(action, box_size)


func _fight_transition_tween(previous_action: Action, box_size := Vector2(148.0, 148.0)) -> void:
	if _tween_start:
		var tween_size := create_tween()
		var tween_size_y := create_tween()
		#var tween_pos := create_tween()
		
		tween_size.tween_property(text_box, "size:x", box_size.x, 0.5)
		tween_size_y.tween_property(text_box, "size:y", box_size.y, 0.5)
		#tween_pos.tween_property($TextBox, "position:x", 246.0, 0.5)
		#text_box.position = Vector2(320.0 - text_box.size.x / 2.0, 480.0 - text_box.size.y - 87.0)
		
		_start_enemy_dialogue()
		
		match previous_action:
			Action.FIGHT:
				var tween_opacity := create_tween()
				tween_opacity.tween_property($TextBox/AttackAccuracy/AttackAccuracyTexture, 
						"modulate:a", 0.0, 0.3)
		
		tween_size.finished.connect(_on_tween_finished)
		
		_tween_start = false


func _act_button_dialogue(line_name: String) -> void:
	var dialogue_label := $TextBox/ActText/Star/DialogueLabel
	
	$TextBox/ActSelect.visible = false
	$TextBox/ItemSelect.visible = false
	$TextBox/ActText.visible = true
	_selected_action = Action.DISPLAY_ACT
	
	dialogue_label.dialogue_line = await DAMN_BIRD_DIALOGUE.\
			get_next_dialogue_line(line_name)
	dialogue_label.type_out()
	soul.global_position = Vector2(-20, -20)


func _back_to_main_act(previous_button: Button) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		info_text.visible = true
		target.visible = false
		$TextBox/ItemSelect.visible = false
		_selected_action = Action.NONE
		previous_button.grab_focus()
		$TextBox/Target/DamnBirdSelect.release_focus()


func _start_enemy_dialogue() -> void:
	var enemy_dialogue: DialogueLabel = %DamnBird/DialogueBaloon/NinePatchRect/DialogueLabel
	
	%DamnBird/DialogueBaloon.visible = true
	enemy_dialogue.dialogue_line = await DAMN_BIRD_DIALOGUE.get_next_dialogue_line("start")
	enemy_dialogue.type_out()


func _on_enemy_dialogue_finished():
	_enemy_dialogue_finished = true


func _on_tween_finished():
	soul.visible = false
	soul.global_position = Vector2(320.0, 320.0)
	_fight_ready = true
	$TextBox/AttackAccuracy.visible = false
	_selected_action = Action.ENEMY_TURN


func _on_tween_finished_reset():
	_attack_start = true
	_accept_input = false
	_delay = 0.0
	_tween_start = true
	_dialogue_finished = false
	_enemy_dialogue_finished = false
	_fight_ready = false
	_select_attack_type = true
	
	match _last_selected_main_act:
		0:
			$ActionButtons/FightButton.grab_focus()
		1:
			$ActionButtons/ActButton.grab_focus()
		2:
			$ActionButtons/ItemButton.grab_focus()
		3:
			$ActionButtons/MercyButton.grab_focus()

	_selected_action = Action.NONE
	attack_point.visible = true
	info_text.visible = true
	$TextBox/AttackAccuracy/AttackPoint/Sprite/AnimationPlayer.play("RESET")


func _on_dialogue_label_finished_typing() -> void:
	_dialogue_finished = true


func _on_fight_button_button_down() -> void:
	info_text.visible = false
	target.visible = true
	_selected_action = Action.FIGHT
	_last_selected_main_act = 0
	$ActionButtons/FightButton.release_focus()
	$TextBox/Target/DamnBirdSelect.grab_focus()
	soul.global_position = $TextBox/Target/DamnBirdSelect.global_position + Vector2(-16.0, 21.0)


func _on_act_button_button_down() -> void:
	info_text.visible = false
	target.visible = true
	$TextBox/Target/DamnBirdSelect/DamnBirdHealthBar.visible = false
	_selected_action = Action.ACT
	_last_selected_main_act = 1
	$ActionButtons/ActButton.release_focus()
	$TextBox/Target/DamnBirdSelect.grab_focus()
	soul.global_position = $TextBox/Target/DamnBirdSelect.global_position + Vector2(-16.0, 21.0)


func _on_item_button_button_down() -> void:
	for index in range(4):
		if index <= soul.items.size() - 1: _item_select_buttons[index].text = soul.items[index][0]
		else: 
			#_item_select_buttons[index].disabled = true
			_item_select_buttons[index].visible = false
	
	info_text.visible = false
	$TextBox/ItemSelect.visible = true
	_selected_action = Action.ITEM
	_last_selected_main_act = 2
	$ActionButtons/ItemButton.release_focus()
	$TextBox/ItemSelect/Item1Button.grab_focus()
	soul.global_position = $TextBox/ItemSelect/Item1Button.global_position + Vector2(-16.0, 21.0)

func _on_damn_bird_select_button_down() -> void:
	target.visible = false
	$TextBox/Target/DamnBirdSelect.release_focus()
	
	match _selected_action:
		Action.FIGHT:
			_selected_action = Action.FIGHT_START
			$TextBox/AttackAccuracy.visible = true
			attack_point.position.x = 12.0
			soul.global_position = Vector2(-20, -20)
		Action.ACT:
			_selected_action = Action.ACT_SELECT
			$TextBox/ActSelect.visible = true
			_act_buttons[_last_selected_act].grab_focus()


func _on_check_button_button_down() -> void:
	_act_button_dialogue("check")


func _on_act_1_button_button_down() -> void:
	_act_button_dialogue("act1")


func _on_item_1_button_button_down() -> void:
	_use_item(0)


func _on_item_2_button_button_down() -> void:
	_use_item(1)


func _on_item_3_button_button_down() -> void:
	_use_item(2)


func _on_item_4_button_button_down() -> void:
	_use_item(3)


func _on_mercy_button_button_down() -> void:
	_selected_action = Action.ENEMY_TURN
	info_text.visible = false
	soul.global_position = Vector2(-20, -20)
	_last_selected_main_act = 3
	$ActionButtons/MercyButton.release_focus()
	_attack_type_select(Action.MERCY, 2)
