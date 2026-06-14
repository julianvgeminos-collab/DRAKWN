# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does weapon + spell combo feel natural to chain without instruction?
# Date: 2026-06-13

extends Node2D

var player: Player
var hp_bar: ProgressBar
var spell_bar: ProgressBar
var hp_label: Label
var spell_label: Label
var round_over := false

var camera:         Camera2D
var shake_timer    := 0.0
var shake_strength := 0.0

func _ready() -> void:
	position = Vector2.ZERO  # cancel any editor offset
	_setup_input()
	_setup_world()
	_setup_player()
	_setup_enemies()
	_setup_ui()

func _process(delta: float) -> void:
	# Camera shake decay
	if shake_timer > 0.0:
		shake_timer = maxf(0.0, shake_timer - delta)
		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		camera.offset = Vector2.ZERO

	if not round_over and get_tree().get_nodes_in_group("enemies").size() == 0:
		round_over = true
		_show_message("¡RONDA SUPERADA! Recargando...")
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()

# Called by Player and Enemy on any hit — freeze + shake
func impact_feedback(strength: float = 8.0) -> void:
	shake_strength = strength
	shake_timer    = 0.18
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.055, true, false, true).timeout
	Engine.time_scale = 1.0

func _setup_input() -> void:
	_bind_key("move_left",  KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("jump",       KEY_SPACE)
	_bind_key("attack",     KEY_Z)
	_bind_key("spell",      KEY_X)

func _bind_key(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	else:
		InputMap.action_erase_events(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(action, ev)

func _setup_world() -> void:
	# Fixed camera centered on the world (needed for screen shake)
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	add_child(camera)

	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.07, 0.07, 0.11)
	add_child(bg)

	_make_platform(Vector2(640, 700), Vector2(1280, 40))   # floor
	_make_platform(Vector2(200,  540), Vector2(220,  18))  # left platform
	_make_platform(Vector2(640,  440), Vector2(200,  18))  # center platform
	_make_platform(Vector2(1080, 540), Vector2(220,  18))  # right platform

func _make_platform(center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = center
	add_child(body)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)

	# Main body (dark purple)
	var rect := ColorRect.new()
	rect.size = size
	rect.position = -size / 2.0
	rect.color = Color(0.22, 0.18, 0.30)
	body.add_child(rect)

	# Top edge highlight so platforms look clearly like solid ground
	var edge := ColorRect.new()
	edge.size = Vector2(size.x, 3)
	edge.position = Vector2(-size.x / 2.0, -size.y / 2.0)
	edge.color = Color(0.55, 0.45, 0.75)
	body.add_child(edge)

func _setup_player() -> void:
	player = Player.new()
	player.position = Vector2(180, 640)
	add_child(player)
	player.health_changed.connect(_on_health_changed)
	player.spell_charge_changed.connect(_on_spell_charge_changed)

func _setup_enemies() -> void:
	_spawn_enemy(Vector2(850,  640))   # further right — gives player room to orient
	_spawn_enemy(Vector2(1100, 640))

func _spawn_enemy(pos: Vector2) -> void:
	var enemy := Enemy.new()
	enemy.target = player
	enemy.position = pos
	add_child(enemy)

func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var panel := VBoxContainer.new()
	panel.position = Vector2(20, 16)
	canvas.add_child(panel)

	hp_label = Label.new()
	hp_label.text = "HP: 100 / 100"
	panel.add_child(hp_label)

	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(200, 18)
	hp_bar.max_value = 100
	hp_bar.value = 100
	panel.add_child(hp_bar)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 6)
	panel.add_child(gap)

	spell_label = Label.new()
	spell_label.text = "Fuego: LISTO  [X]"
	panel.add_child(spell_label)

	spell_bar = ProgressBar.new()
	spell_bar.custom_minimum_size = Vector2(200, 18)
	spell_bar.max_value = 100
	spell_bar.value = 100
	panel.add_child(spell_bar)

	var hint := Label.new()
	hint.position = Vector2(300, 692)
	hint.text = "A / D: mover   |   Espacio: saltar   |   Z: espada   |   X: fuego"
	canvas.add_child(hint)

func _show_message(text: String) -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var lbl := Label.new()
	lbl.text = text
	lbl.position = Vector2(440, 320)
	canvas.add_child(lbl)

func _on_health_changed(current: int, maximum: int) -> void:
	hp_bar.value = current
	hp_bar.max_value = maximum
	hp_label.text = "HP: %d / %d" % [current, maximum]

func _on_spell_charge_changed(ratio: float) -> void:
	spell_bar.value = ratio * 100.0
	spell_label.text = "Fuego: LISTO  [X]" if ratio >= 1.0 else "Fuego: recargando..."
