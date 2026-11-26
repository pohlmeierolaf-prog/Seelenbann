class_name Battle
extends CanvasLayer
## Rundenbasierter Kampf gegen eine wilde Kreatur. Ergebnis über Signal finished: "win", "lose", "flee".

signal finished(result: String)
signal _advance

class CreatureView extends Node2D:
	var species := ""
	var t := 0.0
	func _process(delta: float) -> void:
		t += delta
		queue_redraw()
	func _draw() -> void:
		CreatureArt.draw(self, species, t)

var stage: Control
var mine: Dictionary
var foe: Dictionary
var view_mine: CreatureView
var view_foe: CreatureView
var shown_hp := {"mine": 0.0, "foe": 0.0}
var stages := {"mine": 0, "foe": 0}
var msg_label: Label
var menu: GridContainer
var _waiting := false
var _shown_at := 0
var _choice := ""
signal _chosen


func _ready() -> void:
	layer = 15
	visible = false
	stage = Control.new()
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.draw.connect(_draw_stage)
	stage.resized.connect(_layout)
	add_child(stage)
	view_foe = CreatureView.new()
	view_mine = CreatureView.new()
	stage.add_child(view_foe)
	stage.add_child(view_mine)

	msg_label = Label.new()
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_label.add_theme_font_size_override("font_size", 11)
	msg_label.add_theme_color_override("font_color", Color("ddd2c4"))
	stage.add_child(msg_label)

	menu = GridContainer.new()
	menu.columns = 2
	menu.add_theme_constant_override("h_separation", 4)
	menu.add_theme_constant_override("v_separation", 3)
	stage.add_child(menu)


func _layout() -> void:
	if menu == null:
		return
	var s := stage.size
	view_foe.position = Vector2(s.x * 0.68, 60)
	view_foe.scale = Vector2(-2.6, 2.6)
	view_mine.position = Vector2(s.x * 0.25, 116)
	view_mine.scale = Vector2(3.2, 3.2)
	msg_label.position = Vector2(14, s.y - 54)
	msg_label.size = Vector2(s.x - 28, 44)
	menu.position = Vector2(s.x - 196, s.y - 54)
	stage.queue_redraw()


func _process(_delta: float) -> void:
	if visible:
		stage.queue_redraw()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if _waiting and Time.get_ticks_msec() - _shown_at > 200:
		if (event is InputEventScreenTouch and event.pressed) or event.is_action_pressed("interact"):
			_waiting = false
			get_viewport().set_input_as_handled()
			_advance.emit()
	elif menu.visible and event.is_action_pressed("back"):
		_choice = "back"
		_chosen.emit()


# --- Zeichnen ---------------------------------------------------------------

func _draw_stage() -> void:
	var s := stage.size
	stage.draw_rect(Rect2(Vector2.ZERO, s), Color("0b0910"))
	for i in 6:
		stage.draw_rect(Rect2(0, 40 + i * 14, s.x, 14), Color(0.25, 0.2, 0.35, 0.03 * (6 - i)))
	_ellipse(Vector2(s.x * 0.68, 87), 46, 9, Color("1e1a26"))
	_ellipse(Vector2(s.x * 0.25, 148), 60, 11, Color("1e1a26"))
	# Mondsichel
	stage.draw_circle(Vector2(s.x * 0.47, 22), 8, Color("d8d0c0"))
	stage.draw_circle(Vector2(s.x * 0.47 + 3, 20), 7, Color("0b0910"))
	_info_box(Rect2(10, 10, 158, 34), foe, "foe", false)
	_info_box(Rect2(s.x - 170, 106, 160, 42), mine, "mine", true)
	# Textleiste
	var panel := Rect2(6, s.y - 60, s.x - 12, 54)
	stage.draw_rect(panel, Color(0.05, 0.03, 0.07, 0.95))
	stage.draw_rect(panel, Color("7a2a35"), false, 2.0)


func _ellipse(c: Vector2, rx: float, ry: float, col: Color) -> void:
	stage.draw_set_transform(c, 0, Vector2(1, ry / rx))
	stage.draw_circle(Vector2.ZERO, rx, col)
	stage.draw_set_transform(Vector2.ZERO)


func _info_box(r: Rect2, mon: Dictionary, key: String, numbers: bool) -> void:
	if mon.is_empty():
		return
	var font := ThemeDB.fallback_font
	stage.draw_rect(r, Color(0.06, 0.04, 0.08, 0.9))
	stage.draw_rect(r, Color("4a3a55"), false, 1.0)
	stage.draw_string(font, r.position + Vector2(6, 13), Dex.name_of(mon), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("e8dccb"))
	stage.draw_string(font, r.position + Vector2(r.size.x - 34, 13), "Lv %d" % mon["level"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("b0a4b8"))
	var el := Dex.element_of(mon)
	stage.draw_string(font, r.position + Vector2(6, 24), el, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Dex.COLORS[el])
	var ratio := clampf(shown_hp[key] / float(mon["max_hp"]), 0.0, 1.0)
	var bar := Rect2(r.position + Vector2(60, 19), Vector2(r.size.x - 68, 5))
	stage.draw_rect(bar, Color("1a1418"))
	var col := Color("5aa04a") if ratio > 0.5 else (Color("d0a030") if ratio > 0.2 else Color("d03030"))
	stage.draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), col)
	if numbers:
		stage.draw_string(font, r.position + Vector2(r.size.x - 58, 36), "%d / %d" % [roundi(shown_hp[key]), mon["max_hp"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("c8bcc8"))


# --- Ablauf -----------------------------------------------------------------

func start(my_mon: Dictionary, wild: Dictionary) -> void:
	mine = my_mon
	foe = wild
	stages = {"mine": 0, "foe": 0}
	shown_hp = {"mine": float(mine["hp"]), "foe": float(foe["hp"])}
	view_mine.species = mine["species"]
	view_foe.species = foe["species"]
	view_mine.modulate.a = 1.0
	view_foe.modulate.a = 1.0
	menu.visible = false
	visible = true
	_layout()
	await _say("Ein wilder %s erhebt sich aus dem Grabmoos!" % Dex.name_of(foe))
	await _say("Los, %s!" % Dex.name_of(mine))
	var result := ""
	while result == "":
		result = await _round()
	visible = false
	finished.emit(result)


func _say(text: String) -> void:
	menu.visible = false
	msg_label.size.x = stage.size.x - 28
	msg_label.text = text
	_waiting = true
	_shown_at = Time.get_ticks_msec()
	await _advance


func _button(text: String, value: String, col := Color("ddd2c4")) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(88, 22)
	b.add_theme_font_size_override("font_size", 10)
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_focus_color", col.lightened(0.3))
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("1c1424") if state == "normal" else Color("3a1c28")
		sb.border_color = Color("7a2a35") if state in ["focus", "hover"] else Color("3a2e44")
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(2)
		b.add_theme_stylebox_override(state, sb)
	b.pressed.connect(func(): _choice = value; _chosen.emit())
	menu.add_child(b)


func _open_menu(prompt: String) -> void:
	for c in menu.get_children():
		c.queue_free()
	msg_label.text = prompt
	msg_label.size.x = stage.size.x - 220
	menu.visible = true


func _show_main_menu() -> void:
	_open_menu("Was soll %s tun?" % Dex.name_of(mine))
	_button("Kämpfen", "fight")
	_button("Bannen", "bind")
	_button("Fliehen", "flee")
	await get_tree().process_frame
	(menu.get_child(0) as Button).grab_focus()


func _choose() -> String:
	_choice = ""
	await _chosen
	var c := _choice
	_choice = ""
	return c


func _round() -> String:
	_show_main_menu()
	var action := await _choose()
	match action:
		"bind":
			await _say("Du hast noch keine Seelensteine. (Bannen kommt in Meilenstein 3.)")
			return ""
		"flee":
			if randf() < 0.5 + 0.5 * mine["spd"] / float(mine["spd"] + foe["spd"]):
				await _say("Du entkommst in die Nebel.")
				return "flee"
			await _say("Die Flucht misslingt!")
			await _use_move(foe, foe["moves"].pick_random(), mine, "foe", "mine")
			return await _check_end()
		"fight":
			_open_menu("Welche Attacke?")
			for m in mine["moves"]:
				var mv: Dictionary = Dex.MOVES[m]
				_button(mv["name"], m, Dex.COLORS[mv["element"]])
			_button("Zurück", "back")
			await get_tree().process_frame
			(menu.get_child(0) as Button).grab_focus()
			var move := await _choose()
			if move == "back":
				return ""
			var foe_move: String = foe["moves"].pick_random()
			var mine_first: bool = mine["spd"] > foe["spd"] or (mine["spd"] == foe["spd"] and randf() < 0.5)
			if mine_first:
				await _use_move(mine, move, foe, "mine", "foe")
				if foe["hp"] > 0:
					await _use_move(foe, foe_move, mine, "foe", "mine")
			else:
				await _use_move(foe, foe_move, mine, "foe", "mine")
				if mine["hp"] > 0:
					await _use_move(mine, move, foe, "mine", "foe")
			return await _check_end()
	return ""


func _check_end() -> String:
	if foe["hp"] <= 0:
		await _fade(view_foe)
		await _say("%s zerfällt zu Asche!" % Dex.name_of(foe))
		var xp := int(Dex.SPECIES[foe["species"]]["xp"] * foe["level"] / 5.0)
		mine["xp"] += xp
		await _say("%s nimmt %d Seelenessenz auf." % [Dex.name_of(mine), xp])
		return "win"
	if mine["hp"] <= 0:
		await _fade(view_mine)
		await _say("%s bricht zusammen..." % Dex.name_of(mine))
		await _say("Du schleppst dich zurück nach Rabenstein.")
		return "lose"
	return ""


func _fade(v: Node2D) -> void:
	var tw := create_tween()
	tw.tween_property(v, "modulate:a", 0.0, 0.5)
	await tw.finished


func _use_move(att: Dictionary, move_id: String, def: Dictionary, ak: String, dk: String) -> void:
	var mv: Dictionary = Dex.MOVES[move_id]
	var prefix := "" if ak == "mine" else "Der wilde "
	await _say("%s%s setzt %s ein!" % [prefix, Dex.name_of(att), mv["name"]])
	if randi() % 100 >= mv["acc"]:
		await _say("Die Attacke verfehlt ihr Ziel.")
		return
	if mv.get("effect", "") == "atk_up":
		if stages[ak] >= 2:
			await _say("Die Wut kann nicht weiter steigen.")
		else:
			stages[ak] += 1
			await _say("Der Angriff von %s steigt!" % Dex.name_of(att))
		return
	var eff := Dex.effectiveness(mv["element"], Dex.element_of(def))
	var stab := 1.5 if mv["element"] == Dex.element_of(att) else 1.0
	var atk: float = att["atk"] * (1.0 + 0.5 * stages[ak])
	var base: float = (2.0 * att["level"] / 5.0 + 2.0) * mv["power"] * atk / float(def["def"]) / 50.0 + 2.0
	var dmg := maxi(1, int(base * stab * eff * randf_range(0.85, 1.0)))
	def["hp"] = maxi(0, def["hp"] - dmg)
	await _hit(dk, def["hp"])
	if eff > 1.0:
		await _say("Sehr wirkungsvoll!")
	elif eff < 1.0:
		await _say("Kaum Wirkung...")
	if mv.get("effect", "") == "drain" and att["hp"] > 0:
		att["hp"] = mini(att["max_hp"], att["hp"] + maxi(1, dmg / 2))
		await _hit(ak, att["hp"])
		await _say("%s saugt Lebenskraft ab." % Dex.name_of(att))


func _hit(key: String, new_hp: int) -> void:
	var v := view_mine if key == "mine" else view_foe
	var tw := create_tween()
	for i in 3:
		tw.tween_property(v, "modulate:a", 0.2, 0.06)
		tw.tween_property(v, "modulate:a", 1.0, 0.06)
	tw.tween_method(func(x): shown_hp[key] = x, shown_hp[key], float(new_hp), 0.5)
	await tw.finished
