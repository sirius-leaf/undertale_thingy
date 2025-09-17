class_name SoulController
extends CharacterBody2D


signal hit

const SPEED = 200.0
const POWER = 150.0

var health := 10
var attack := false
var receiving_damage := true
var items := [
	["Bandage", 10, "+10 HP", "bandage"],
	["Monster Candy", 10, "+10 HP", "monster_candy"],
	["Nice Cream", 15, "+15 HP", "nice_cream"],
	["Unisicle", 11, "+11 HP", "unisicle"],
]

var _damaga_delay := 1.0

@onready var collider: CollisionShape2D = $Collider
@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	hit.connect(_on_hit)


func _process(delta: float) -> void:
	if not receiving_damage:
		if _damaga_delay > 0:
			_damaga_delay -= delta
			sprite.visible = true if sin(Time.get_ticks_msec() / 30.0) > 0 else false
		else:
			_damaga_delay = 1.0
			sprite.visible = true
			receiving_damage = true


func _physics_process(delta: float) -> void:
	if attack:
		collider.disabled = false
		
		move()
	else:
		velocity = Vector2.ZERO
		collider.disabled = true

	move_and_slide()


func move() -> void:
	var direction := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO


func _on_hit():
	pass
