# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does weapon + spell combo feel natural to chain without instruction?
# Date: 2026-06-13

class_name Player
extends CharacterBody2D

const SPEED         := 260.0
const JUMP_VELOCITY := -520.0
const GRAVITY       := 980.0
const ATTACK_COOLDOWN := 0.35
const SPELL_COOLDOWN  := 3.0
const MAX_HEALTH      := 100

signal health_changed(current: int, maximum: int)
signal spell_charge_changed(ratio: float)

var health         := MAX_HEALTH
var attack_timer   := 0.0
var spell_timer    := 0.0
var invincible_timer := 0.0
var facing_right   := true

var body_rect:    ColorRect
var attack_flash: ColorRect

func _ready() -> void:
	# Blue rectangle body
	body_rect = ColorRect.new()
	body_rect.size = Vector2(30, 48)
	body_rect.position = Vector2(-15, -48)
	body_rect.color = Color(0.30, 0.55, 1.0)
	add_child(body_rect)

	# Collision shape
	var col   := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(30, 48)
	col.shape  = shape
	col.position = Vector2(0, -24)
	add_child(col)

	# Yellow flash that appears during sword swing
	attack_flash = ColorRect.new()
	attack_flash.size = Vector2(44, 32)
	attack_flash.color = Color(1.0, 0.92, 0.20, 0.90)
	attack_flash.visible = false
	add_child(attack_flash)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0:
		velocity.x = dir * SPEED
		facing_right = dir > 0
	else:
		velocity.x = 0.0

	attack_timer     = maxf(0.0, attack_timer     - delta)
	spell_timer      = maxf(0.0, spell_timer      - delta)
	invincible_timer = maxf(0.0, invincible_timer - delta)

	if attack_timer <= 0.0:
		attack_flash.visible = false

	var charge := 1.0 if spell_timer <= 0.0 else 1.0 - spell_timer / SPELL_COOLDOWN
	spell_charge_changed.emit(charge)

	if Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
		_attack()
	if Input.is_action_just_pressed("spell") and spell_timer <= 0.0:
		_cast_spell()

	move_and_slide()

func _attack() -> void:
	attack_timer = ATTACK_COOLDOWN

	# Position flash to the correct side
	attack_flash.position.x = 15.0 if facing_right else -59.0
	attack_flash.position.y = -40.0
	attack_flash.visible = true

	# Melee hit: enemies within 65 px in front of the player
	var side       := 1 if facing_right else -1
	var hit_center := global_position + Vector2(55.0 * side, -24.0)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and hit_center.distance_to(enemy.global_position) < 65.0:
			enemy.take_damage(25, side)

func _cast_spell() -> void:
	spell_timer = SPELL_COOLDOWN
	var spell := FireSpell.new()
	spell.direction = Vector2.RIGHT if facing_right else Vector2.LEFT
	spell.position  = global_position + Vector2(0, -24)
	get_parent().add_child(spell)

func take_damage(amount: int, _from_dir: int = 0) -> void:
	if invincible_timer > 0.0:
		return
	invincible_timer = 0.6
	health = max(0, health - amount)
	health_changed.emit(health, MAX_HEALTH)

	body_rect.color = Color.RED
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(body_rect):
		body_rect.color = Color(0.30, 0.55, 1.0)

	if health <= 0:
		get_tree().reload_current_scene()
