class_name UiController
extends Control


enum Action { NONE, FIGHT, ACT, ITEM, MERCY, FIGHT_START, ACT_SELECT, ENEMY_TURN }

const ATTACK_SPEED = 300.0

var selected_action: Action
var attack_start := true
var accept_input := false
var delay := 0.0
var tween_start := true

@onready var target: Control = $TextBox/Target
@onready var soul: SoulController = $"../../Soul"
@onready var attack_point: Control = $TextBox/AttackAccuracy/AttackPoint
@onready var damn_bird: DamnBirdController = $"../../DamnBird"
@onready var damn_bird_health_bar: ProgressBar = $TextBox/Target/DamnBirdSelect/DamnBirdHealthBar
@onready var damn_bird_health_bar_2: ProgressBar = $"../../DamnBird/DamnBirdHealthBar2"
@onready var info_text: Control = $TextBox/InfoText
@onready var health_bar: ProgressBar = $HealthInfo/HealthBar
@onready var health_label: Label = $HealthInfo/HealthLabel

@onready var buttons: Array[Button] = [
	$ActionButtons/FightButton, 
	$ActionButtons/ActButton,
	$ActionButtons/ItemButton,
	$ActionButtons/MercyButton
]


func _ready() -> void:
	damn_bird_health_bar.value = damn_bird.health
	damn_bird_health_bar_2.value = damn_bird.health
	health_bar.value = soul.health
	attack_point.position.x = 12.0
	
	$ActionButtons/FightButton.grab_focus()


func _process(delta: float) -> void:
	
	match selected_action:
		Action.FIGHT_START:
			_attack(delta)
			_attack_end(delta)
		Action.ENEMY_TURN:
			health_bar.value = soul.health
			health_label.text = str(soul.health) + " / 30"
		Action.NONE:
			target.visible = false
			soul.visible = true
			
			for item in buttons:
				if item.has_focus():
					soul.global_position = item.global_position + Vector2(16.0, 22.0)
					break


func reset() -> void:
	var tween_size := create_tween()
	var tween_pos := create_tween()
	
	tween_size.tween_property($TextBox, "size:x", 600.0, 0.5)
	tween_pos.tween_property($TextBox, "position:x", 20.0, 0.5)
	tween_size.finished.connect(_on_tween_finished_reset)
	$TextBox/AttackAccuracy/AttackAccuracyTexture.modulate.a = 1.0 
	
	soul.visible = false


func _attack(delta: float) -> void:
	if attack_point.position.x < 588.0:
		if Input.is_action_just_released("ui_accept") and not accept_input:
			accept_input = true
		
		if attack_start:
			attack_point.position.x += ATTACK_SPEED * delta
		
		if Input.is_action_just_pressed("ui_accept") and accept_input and attack_start:
			damn_bird.health -= round((300 - abs(attack_point.position.x - 300)) / 300
					* soul.POWER)
			damn_bird_health_bar.value = damn_bird.health
			damn_bird_health_bar_2.value = damn_bird.health
			damn_bird_health_bar_2.visible = true
					
			$TextBox/AttackAccuracy/AttackPoint/Sprite/AnimationPlayer.play("attack")
			print(round((300 - abs(attack_point.position.x - 300)) / 300 * soul.POWER))
			
			delay = 1.5
			attack_start = false
	elif attack_start:
		delay = 1.5
		
		#damn_bird_health_bar_2.visible = true
		$TextBox/AttackAccuracy/AttackPoint/Sprite/AnimationPlayer.play("attack")
		
		attack_start = false


func _attack_end(delta: float) -> void:
	if delay > 0:
		delay -= delta
	elif not attack_start:
		attack_point.visible = false
		damn_bird_health_bar_2.visible = false
	
		if tween_start:
				var tween_size := create_tween()
				var tween_pos := create_tween()
				var tween_opacity := create_tween()
				
				tween_size.tween_property($TextBox, "size:x", 148.0, 1.0)
				tween_pos.tween_property($TextBox, "position:x", 246.0, 1.0)
				tween_opacity.tween_property($TextBox/AttackAccuracy/AttackAccuracyTexture, 
						"modulate:a", 0.0, 0.5)
				tween_size.finished.connect(_on_tween_finished)
				
				tween_start = false


func _on_tween_finished():
	soul.global_position = Vector2(320.0, 320.0)
	soul.attack = true
	$TextBox/AttackAccuracy.visible = false
	selected_action = Action.ENEMY_TURN


func _on_tween_finished_reset():
	attack_start = true
	accept_input = false
	delay = 0.0
	tween_start = true
	
	$ActionButtons/FightButton.grab_focus()
	selected_action = Action.NONE
	attack_point.visible = true
	info_text.visible = true
	$TextBox/AttackAccuracy/AttackPoint/Sprite/AnimationPlayer.play("RESET")


func _on_fight_button_button_down() -> void:
	info_text.visible = false
	target.visible = true
	selected_action = Action.FIGHT
	$ActionButtons/FightButton.release_focus()
	$TextBox/Target/DamnBirdSelect.grab_focus()
	soul.global_position = $TextBox/Target/DamnBirdSelect.global_position + Vector2(-16.0, 21.0)


func _on_act_button_button_down() -> void:
	info_text.visible = false
	target.visible = true
	selected_action = Action.ACT
	$ActionButtons/ActButton.release_focus()
	$TextBox/Target/DamnBirdSelect.grab_focus()
	soul.global_position = $TextBox/Target/DamnBirdSelect.global_position + Vector2(-16.0, 21.0)


func _on_damn_bird_select_button_down() -> void:
	target.visible = false
	
	match selected_action:
		Action.FIGHT:
			selected_action = Action.FIGHT_START
			$TextBox/AttackAccuracy.visible = true
			attack_point.position.x = 12.0
		Action.ACT:
			selected_action = Action.ACT_SELECT
			
	
	soul.global_position = Vector2(-20, -20)
	$TextBox/Target/DamnBirdSelect.release_focus()
