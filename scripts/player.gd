class_name Player
extends Node2D
## Der Seelenbanner: läuft Kachel für Kachel über die Karte.

signal moved(cell: Vector2i)

const TILE := 16
const STEP_TIME := 0.17

var world: WorldMap
var cell := Vector2i.ZERO
var facing := Vector2i.DOWN
var moving := false
var frozen := false
var _anim := 0.0


func place(c: Vector2i, dir: Vector2i) -> void:
	cell = c
	facing = dir
	position = Vector2(c * TILE)
	queue_redraw()


func _process(delta: float) -> void:
	if moving:
		_anim += delta * 12.0
		queue_redraw()
		return
	if frozen:
		return
	var dir := _input_dir()
	if dir == Vector2i.ZERO:
		if _anim != 0.0:
			_anim = 0.0
			queue_redraw()
		return
	if dir != facing:
		facing = dir
		queue_redraw()
	var target := cell + dir
	if world.is_walkable(target):
		_step(target)


func _input_dir() -> Vector2i:
	if Input.is_action_pressed("move_up"):
		return Vector2i.UP
	if Input.is_action_pressed("move_down"):
		return Vector2i.DOWN
	if Input.is_action_pressed("move_left"):
		return Vector2i.LEFT
	if Input.is_action_pressed("move_right"):
		return Vector2i.RIGHT
	return Vector2i.ZERO


func _step(target: Vector2i) -> void:
	moving = true
	cell = target
	var tw := create_tween()
	tw.tween_property(self, "position", Vector2(target * TILE), STEP_TIME)
	await tw.finished
	moving = false
	moved.emit(cell)


func _draw() -> void:
	# Lichtschein der Laterne, die der Held trägt
	draw_circle(Vector2(8, 8), 30, Color(1.0, 0.8, 0.5, 0.035))
	draw_circle(Vector2(8, 8), 18, Color(1.0, 0.8, 0.5, 0.05))
	var bob := -1.0 if moving and int(_anim) % 2 == 0 else 0.0
	var o := Vector2(0, bob)
	draw_circle(Vector2(8, 15), 5, Color(0, 0, 0, 0.35))
	# Umhang
	var cloak := Color("2b2238")
	var cloak_dark := Color("1c1626")
	draw_colored_polygon(PackedVector2Array([o + Vector2(3, 15), o + Vector2(13, 15), o + Vector2(11, 6), o + Vector2(5, 6)]), cloak)
	# Beine
	var step := int(_anim) % 2 if moving else 0
	draw_rect(Rect2(o + Vector2(5 + step, 14), Vector2(2, 2)), cloak_dark)
	draw_rect(Rect2(o + Vector2(9 - step, 14), Vector2(2, 2)), cloak_dark)
	# Kapuze
	draw_circle(o + Vector2(8, 5), 4.5, cloak)
	var skin := Color("c9b8a6")
	var eye := Color("1a1220")
	match facing:
		Vector2i.DOWN:
			draw_rect(Rect2(o + Vector2(6, 4), Vector2(4, 4)), skin)
			draw_rect(Rect2(o + Vector2(6, 5), Vector2(1, 1)), eye)
			draw_rect(Rect2(o + Vector2(9, 5), Vector2(1, 1)), eye)
			draw_line(o + Vector2(8, 9), o + Vector2(8, 14), Color("b02a35"), 1.0)
		Vector2i.UP:
			draw_circle(o + Vector2(8, 6), 3, cloak_dark)
		Vector2i.LEFT:
			draw_rect(Rect2(o + Vector2(4, 4), Vector2(3, 4)), skin)
			draw_rect(Rect2(o + Vector2(4, 5), Vector2(1, 1)), eye)
		Vector2i.RIGHT:
			draw_rect(Rect2(o + Vector2(9, 4), Vector2(3, 4)), skin)
			draw_rect(Rect2(o + Vector2(11, 5), Vector2(1, 1)), eye)
	# Laterne in der Hand
	var lx := 12.0 if facing != Vector2i.LEFT else 3.0
	draw_rect(Rect2(o + Vector2(lx, 10), Vector2(2, 3)), Color("e8b858"))
