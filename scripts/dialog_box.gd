class_name DialogBox
extends CanvasLayer
## Textbox am unteren Bildschirmrand mit Schreibmaschinen-Effekt.

signal closed

var is_open := false
var _pages: Array = []
var _index := 0
var _label: Label
var _tween: Tween


func _ready() -> void:
	layer = 10
	visible = false
	var panel := PanelContainer.new()
	var touch := DisplayServer.is_touchscreen_available()
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 104 if touch else 8
	panel.offset_right = -104 if touch else -8
	panel.offset_top = -58
	panel.offset_bottom = -6
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.03, 0.07, 0.94)
	style.border_color = Color("7a2a35")
	style.set_border_width_all(2)
	style.set_corner_radius_all(3)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 11)
	_label.add_theme_color_override("font_color", Color("ddd2c4"))
	panel.add_child(_label)


func show_text(pages) -> void:
	_pages = pages if pages is Array else [str(pages)]
	_index = 0
	is_open = true
	visible = true
	_show_page()


func _show_page() -> void:
	_label.text = _pages[_index]
	_label.visible_ratio = 0.0
	_tween = create_tween()
	_tween.tween_property(_label, "visible_ratio", 1.0, 0.02 * _label.text.length())


func advance() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
		_label.visible_ratio = 1.0
		return
	_index += 1
	if _index >= _pages.size():
		visible = false
		is_open = false
		closed.emit()
	else:
		_show_page()
