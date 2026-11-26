class_name TouchControls
extends Control
## Steuerkreuz links, A/B-Tasten rechts. Löst dieselben Aktionen aus wie die Tastatur.

const DIRS := {
	"move_up": Vector2i.UP, "move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT, "move_right": Vector2i.RIGHT,
}

var _pad_touch := -1
var _dir := Vector2i.ZERO
var _buttons := {} # Touch-Index -> Aktion


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = DisplayServer.is_touchscreen_available()
	resized.connect(queue_redraw)


func _pad_center() -> Vector2:
	return Vector2(54, size.y - 54)


func _a_pos() -> Vector2:
	return Vector2(size.x - 36, size.y - 62)


func _b_pos() -> Vector2:
	return Vector2(size.x - 76, size.y - 34)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < size.x * 0.4 and event.position.y > size.y * 0.35:
				_pad_touch = event.index
				_update_pad(event.position)
			elif event.position.distance_to(_a_pos()) < 28:
				_press(event.index, "interact")
			elif event.position.distance_to(_b_pos()) < 24:
				_press(event.index, "back")
		else:
			if event.index == _pad_touch:
				_pad_touch = -1
				_set_dir(Vector2i.ZERO)
			if _buttons.has(event.index):
				Input.action_release(_buttons[event.index])
				_buttons.erase(event.index)
		queue_redraw()
	elif event is InputEventScreenDrag and event.index == _pad_touch:
		_update_pad(event.position)


func _press(index: int, action: String) -> void:
	_buttons[index] = action
	Input.action_press(action)


func _update_pad(pos: Vector2) -> void:
	var v := pos - _pad_center()
	if v.length() < 8:
		_set_dir(Vector2i.ZERO)
	elif absf(v.x) > absf(v.y):
		_set_dir(Vector2i.RIGHT if v.x > 0 else Vector2i.LEFT)
	else:
		_set_dir(Vector2i.DOWN if v.y > 0 else Vector2i.UP)


func _set_dir(d: Vector2i) -> void:
	if d == _dir:
		return
	_dir = d
	for action in DIRS:
		if DIRS[action] == d:
			Input.action_press(action)
		else:
			Input.action_release(action)
	queue_redraw()


func _draw() -> void:
	var c := _pad_center()
	draw_circle(c, 38, Color(1, 1, 1, 0.06))
	draw_arc(c, 38, 0, TAU, 40, Color(1, 1, 1, 0.18), 1.5)
	for action in DIRS:
		var d: Vector2 = Vector2(DIRS[action])
		var tip := c + d * 30
		var side := Vector2(-d.y, d.x) * 7
		var base := c + d * 18
		var col := Color(0.9, 0.3, 0.35, 0.8) if DIRS[action] == _dir else Color(1, 1, 1, 0.35)
		draw_colored_polygon(PackedVector2Array([tip, base + side, base - side]), col)
	_button(_a_pos(), 20, "A", "interact")
	_button(_b_pos(), 16, "B", "back")


func _button(pos: Vector2, r: float, label: String, action: String) -> void:
	var active := action in _buttons.values()
	draw_circle(pos, r, Color(0.7, 0.15, 0.2, 0.55) if active else Color(1, 1, 1, 0.08))
	draw_arc(pos, r, 0, TAU, 32, Color(1, 1, 1, 0.25), 1.5)
	var font := ThemeDB.fallback_font
	draw_string(font, pos + Vector2(-5, 5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, 0.7))
