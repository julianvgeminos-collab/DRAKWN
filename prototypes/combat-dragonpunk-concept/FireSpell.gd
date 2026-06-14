# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does weapon + spell combo feel natural to chain without instruction?
# Date: 2026-06-13

class_name FireSpell
extends Node2D

const SPEED    := 430.0
const DAMAGE   := 40
const LIFETIME := 1.8

var direction    := Vector2.RIGHT
var life_elapsed := 0.0

var core: ColorRect
var glow: ColorRect

func _ready() -> void:
	# Outer glow (larger, semi-transparent)
	glow = ColorRect.new()
	glow.size = Vector2(28, 18)
	glow.position = Vector2(-14, -9)
	glow.color = Color(1.0, 0.45, 0.05, 0.40)
	add_child(glow)

	# Core fireball
	core = ColorRect.new()
	core.size = Vector2(18, 12)
	core.position = Vector2(-9, -6)
	core.color = Color(1.0, 0.62, 0.10)
	add_child(core)

func _process(delta: float) -> void:
	position += direction * SPEED * delta
	life_elapsed += delta

	# Pulse animation (cheap but gives life to the fireball)
	var pulse := sin(life_elapsed * 22.0) * 0.12 + 0.88
	core.scale = Vector2(pulse, pulse)

	if life_elapsed >= LIFETIME:
		queue_free()
		return

	# Distance-based hit detection against all enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) < 34.0:
			enemy.take_damage(DAMAGE, int(direction.x))
			queue_free()
			return
