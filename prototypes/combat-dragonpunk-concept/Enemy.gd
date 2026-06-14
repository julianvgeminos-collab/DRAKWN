# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does weapon + spell combo feel natural to chain without instruction?
# Date: 2026-06-13

class_name Enemy
extends CharacterBody2D

const SPEED           := 85.0
const GRAVITY         := 980.0
const MAX_HEALTH      := 60
const CONTACT_DAMAGE  := 10
const CONTACT_COOLDOWN := 0.8

var health        := MAX_HEALTH
var target:       Node2D
var contact_timer := 0.0

var body_rect: ColorRect
var hp_fill:   ColorRect

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 2  # enemies live on layer 2
	collision_mask  = 1  # only collide with world (layer 1), not with player

	# Red-orange rectangle body
	body_rect = ColorRect.new()
	body_rect.size = Vector2(34, 52)
	body_rect.position = Vector2(-17, -52)
	body_rect.color = Color(0.85, 0.20, 0.15)
	add_child(body_rect)

	var col   := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(34, 52)
	col.shape  = shape
	col.position = Vector2(0, -26)
	add_child(col)

	# HP bar background
	var hp_bg := ColorRect.new()
	hp_bg.size = Vector2(34, 5)
	hp_bg.position = Vector2(-17, -60)
	hp_bg.color = Color(0.2, 0.2, 0.2)
	add_child(hp_bg)

	# HP bar fill (green)
	hp_fill = ColorRect.new()
	hp_fill.size = Vector2(34, 5)
	hp_fill.position = Vector2(-17, -60)
	hp_fill.color = Color(0.2, 0.8, 0.2)
	add_child(hp_fill)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	contact_timer = maxf(0.0, contact_timer - delta)

	if is_instance_valid(target):
		var dir := signf(target.global_position.x - global_position.x)
		velocity.x = dir * SPEED

		var dist     := global_position.distance_to(target.global_position)
		var push_dir := int(signf(target.global_position.x - global_position.x))
		if dist < 38.0 and contact_timer <= 0.0:
			target.take_damage(CONTACT_DAMAGE, push_dir)
			contact_timer = CONTACT_COOLDOWN
	else:
		velocity.x = 0.0

	move_and_slide()

func take_damage(amount: int, knockback_dir: int = 0) -> void:
	health = max(0, health - amount)
	hp_fill.size.x = 34.0 * float(health) / float(MAX_HEALTH)

	# Physical launch: flies up and to the side — more force = bigger arc
	if knockback_dir != 0:
		velocity.x = float(knockback_dir) * 420.0
		velocity.y = -360.0

	# Screen impact scaled by damage (sword: ~6, spell: ~10)
	var shake := clampf(float(amount) * 0.25, 4.0, 12.0)
	var main  := get_tree().current_scene
	if main.has_method("impact_feedback"):
		main.impact_feedback(shake)

	body_rect.color = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(body_rect):
		body_rect.color = Color(0.85, 0.20, 0.15)

	if health <= 0:
		queue_free()
