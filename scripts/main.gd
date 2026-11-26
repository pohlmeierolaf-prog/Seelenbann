extends Node2D
## Hauptszene: baut Welt, Held, Kamera und Oberfläche zusammen.

const INPUTS := {
	"move_up": [KEY_UP, KEY_W],
	"move_down": [KEY_DOWN, KEY_S],
	"move_left": [KEY_LEFT, KEY_A],
	"move_right": [KEY_RIGHT, KEY_D],
	"interact": [KEY_SPACE, KEY_ENTER, KEY_E],
	"back": [KEY_ESCAPE, KEY_X, KEY_BACKSPACE],
}
const ENCOUNTER_CHANCE := 0.1
const HOME := {"map": "rabenstein", "pos": Vector2i(24, 15), "dir": Vector2i.DOWN}

var world: WorldMap
var player: Player
var camera: Camera2D
var dialog: DialogBox
var battle: Battle
var touch: TouchControls
var map_id := ""
var party: Array = [Dex.make("knochenwelpe", 6)]
var fade: ColorRect
var banner: Label
var title: Control
var in_title := true
var busy := false


func _ready() -> void:
	_setup_input()
	RenderingServer.set_default_clear_color(Color("07060a"))

	var tint := CanvasModulate.new()
	tint.color = Color(0.82, 0.78, 0.92)
	add_child(tint)

	world = WorldMap.new()
	add_child(world)
	player = Player.new()
	player.world = world
	player.frozen = true
	player.moved.connect(_on_player_moved)
	add_child(player)
	camera = Camera2D.new()
	camera.position = Vector2(8, 8)
	player.add_child(camera)

	_build_ui()
	_load_map("rabenstein", Vector2i(24, 15), Vector2i.DOWN)


func _setup_input() -> void:
	for action in INPUTS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in INPUTS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)


func _full_rect(c: Control) -> Control:
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _layer(n: int) -> CanvasLayer:
	var l := CanvasLayer.new()
	l.layer = n
	add_child(l)
	return l


func _build_ui() -> void:
	# Vignette: dunkle Ränder für die gotische Stimmung
	var vignette := _full_rect(ColorRect.new())
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = """shader_type canvas_item;
void fragment() {
	vec2 d = (UV - 0.5) * vec2(1.5, 1.0);
	COLOR = vec4(0.02, 0.0, 0.04, smoothstep(0.3, 0.8, length(d)) * 0.85);
}"""
	mat.shader = sh
	vignette.material = mat
	_layer(1).add_child(vignette)

	banner = Label.new()
	banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner.offset_top = 10
	banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 14)
	banner.add_theme_color_override("font_color", Color("d8c8b0"))
	banner.add_theme_color_override("font_outline_color", Color("2a0a10"))
	banner.add_theme_constant_override("outline_size", 4)
	banner.modulate.a = 0.0
	_layer(6).add_child(banner)

	touch = TouchControls.new()
	_layer(5).add_child(touch)
	battle = Battle.new()
	add_child(battle)

	dialog = DialogBox.new()
	add_child(dialog)

	fade = _full_rect(ColorRect.new())
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	_layer(20).add_child(fade)

	title = _full_rect(ColorRect.new())
	(title as ColorRect).color = Color("07060a")
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	title.add_child(box)
	var t := Label.new()
	t.text = "SEELENBANN"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 38)
	t.add_theme_color_override("font_color", Color("b02a35"))
	t.add_theme_color_override("font_outline_color", Color("1a0508"))
	t.add_theme_constant_override("outline_size", 8)
	box.add_child(t)
	var sub := Label.new()
	sub.text = "Banne ihre Seelen. Führe sie in die Finsternis."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 11)
	sub.add_theme_color_override("font_color", Color("8a7f90"))
	box.add_child(sub)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 26)
	box.add_child(gap)
	var hint := Label.new()
	hint.text = "– Tippen oder Leertaste –"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("d8c8b0"))
	box.add_child(hint)
	var blink := hint.create_tween().set_loops()
	blink.tween_property(hint, "modulate:a", 0.25, 0.8)
	blink.tween_property(hint, "modulate:a", 1.0, 0.8)
	_layer(30).add_child(title)


func _input(event: InputEvent) -> void:
	if in_title and ((event is InputEventScreenTouch and event.pressed) or (event is InputEventKey and event.pressed and not event.echo)):
		get_viewport().set_input_as_handled()
		_start_game()


func _process(_delta: float) -> void:
	if in_title or busy:
		return
	if Input.is_action_just_pressed("interact"):
		if dialog.is_open:
			dialog.advance()
		elif not player.moving:
			_interact()


func _start_game() -> void:
	in_title = false
	var tw := create_tween()
	tw.tween_property(title, "modulate:a", 0.0, 0.6)
	await tw.finished
	title.visible = false
	_show_banner()
	if OS.has_feature("web") and str(JavaScriptBridge.eval("location.hash")) == "#kampf":
		map_id = "friedhof"
		_start_battle()
		return
	await _say(["Mutter hat dir ihren alten Knochenwelpen anvertraut.", "Im Grabmoos des Friedhofs lauern wilde Kreaturen. Zu Hause kannst du dich ausruhen."])


func _load_map(id: String, pos: Vector2i, dir: Vector2i) -> void:
	map_id = id
	world.load_map(id)
	player.place(pos, dir)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = world.width * WorldMap.TILE
	camera.limit_bottom = world.height * WorldMap.TILE
	camera.reset_smoothing()


func _show_banner() -> void:
	banner.text = world.map_name
	var tw := create_tween()
	tw.tween_property(banner, "modulate:a", 1.0, 0.4)
	tw.tween_interval(1.8)
	tw.tween_property(banner, "modulate:a", 0.0, 0.6)


func _say(pages) -> void:
	player.frozen = true
	dialog.show_text(pages)
	await dialog.closed
	player.frozen = false


func _interact() -> void:
	var target := player.cell + player.facing
	if world.data.get("actions", {}).get(target, "") == "heal":
		for mon in party:
			mon["hp"] = mon["max_hp"]
		_say(["Du ruhst dich zu Hause aus.", "%s ist wieder bei voller Kraft." % Dex.name_of(party[0])])
		return
	var text = world.get_sign(target)
	if text != null:
		_say(text)


func _on_player_moved(cell: Vector2i) -> void:
	var warp = world.get_warp(cell)
	if warp != null:
		_warp(warp)
	elif world.encounters and world.tile_at(cell) == "\"" and randf() < ENCOUNTER_CHANCE:
		_start_battle()


func _start_battle() -> void:
	busy = true
	player.frozen = true
	touch.visible = false
	var tw := create_tween()
	for i in 2:
		tw.tween_property(fade, "modulate:a", 0.8, 0.12)
		tw.tween_property(fade, "modulate:a", 0.0, 0.12)
	tw.tween_property(fade, "modulate:a", 1.0, 0.2)
	await tw.finished
	battle.start(party[0], Dex.random_encounter(map_id))
	fade.modulate.a = 0.0
	var result: String = await battle.finished
	touch.visible = DisplayServer.is_touchscreen_available()
	if result == "lose":
		for mon in party:
			mon["hp"] = mon["max_hp"]
		fade.modulate.a = 1.0
		_load_map(HOME["map"], HOME["pos"], HOME["dir"])
		tw = create_tween()
		tw.tween_property(fade, "modulate:a", 0.0, 0.5)
		await tw.finished
		busy = false
		await _say("Du erwachst zu Hause. %s ist geheilt." % Dex.name_of(party[0]))
		return
	busy = false
	player.frozen = false


func _warp(w: Dictionary) -> void:
	busy = true
	player.frozen = true
	var tw := create_tween()
	tw.tween_property(fade, "modulate:a", 1.0, 0.3)
	await tw.finished
	_load_map(w["map"], w["pos"], w["dir"])
	tw = create_tween()
	tw.tween_property(fade, "modulate:a", 0.0, 0.3)
	await tw.finished
	player.frozen = false
	busy = false
	_show_banner()
