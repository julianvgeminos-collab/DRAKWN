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
	# Outer glow — wide orange halo
	glow = ColorRect.new()
	glow.size = Vector2(56, 28)
	glow.position = Vector2(-28, -14)
	glow.color = Color(1.0, 0.40, 0.02, 0.50)
	add_child(glow)

	# Core fireball — bright yellow-orange, clearly visible
	core = ColorRect.new()
	core.size = Vector2(36, 20)
	core.position = Vector2(-18, -10)
	core.color = Color(1.0, 0.75, 0.10)
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
