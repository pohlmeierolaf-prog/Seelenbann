class_name CreatureArt
extends RefCounted
## Zeichnet Kreaturen per Code. Koordinaten etwa -12..12, Mitte = Bodenmitte bei y=10.

static func _poly(ci: CanvasItem, pts: Array, col: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array(pts), col)


static func _eyes(ci: CanvasItem, a: Vector2, b: Vector2, col: Color, r := 1.2) -> void:
	ci.draw_circle(a, r + 0.8, Color(col, 0.25))
	ci.draw_circle(b, r + 0.8, Color(col, 0.25))
	ci.draw_circle(a, r, col)
	ci.draw_circle(b, r, col)


static func draw(ci: CanvasItem, species: String, t: float) -> void:
	var bob := sin(t * 3.0) * 0.8
	match species:
		"grabmotte", "totenfalter":
			var big := species == "totenfalter"
			var k := 1.3 if big else 1.0
			var wing := Color("4a3a5e") if not big else Color("2e2238")
			var wing2 := Color("6a5684") if not big else Color("5a1a2a")
			var f := sin(t * 10.0) * 2.0
			_poly(ci, [Vector2(0, -2 + bob), Vector2(-13 * k, -11 * k + f + bob), Vector2(-11 * k, 1 + bob)], wing)
			_poly(ci, [Vector2(0, -2 + bob), Vector2(13 * k, -11 * k + f + bob), Vector2(11 * k, 1 + bob)], wing)
			_poly(ci, [Vector2(0, 0 + bob), Vector2(-9 * k, 7 * k + bob), Vector2(-3, 3 + bob)], wing2)
			_poly(ci, [Vector2(0, 0 + bob), Vector2(9 * k, 7 * k + bob), Vector2(3, 3 + bob)], wing2)
			ci.draw_circle(Vector2(-7 * k, -5 * k + bob), 1.6 * k, Color("c8b8e0"))
			ci.draw_circle(Vector2(7 * k, -5 * k + bob), 1.6 * k, Color("c8b8e0"))
			ci.draw_rect(Rect2(-2, -6 + bob, 4, 11 * k), Color("1c1426"))
			ci.draw_circle(Vector2(0, -7 + bob), 3, Color("1c1426"))
			ci.draw_line(Vector2(-1, -9 + bob), Vector2(-4, -14 + bob), Color("1c1426"), 1.0)
			ci.draw_line(Vector2(1, -9 + bob), Vector2(4, -14 + bob), Color("1c1426"), 1.0)
			if big:
				ci.draw_circle(Vector2(0, -1 + bob), 2, Color("d8cfb0"))
			_eyes(ci, Vector2(-1.3, -7.5 + bob), Vector2(1.3, -7.5 + bob), Color("e0c060"), 0.8)
		"knochenwelpe", "gruftwolf":
			var big := species == "gruftwolf"
			var k := 1.35 if big else 1.0
			var bone := Color("d8cfb0")
			var dark := Color("2a2430")
			if big:
				_poly(ci, [Vector2(-12, 4), Vector2(-10, -6), Vector2(4, -8), Vector2(9, 2), Vector2(4, 6)], Color("2c2632"))
				for i in 4:
					ci.draw_line(Vector2(-8 + i * 3, -7), Vector2(-9 + i * 3, -11), Color("2c2632"), 2.0)
			# Beine
			for x in [-8, -4, 2, 5]:
				ci.draw_line(Vector2(x * k, 2 * k), Vector2(x * k, 9), bone, 1.5)
			# Rippen / Körper
			ci.draw_line(Vector2(-10 * k, 1 * k), Vector2(5 * k, 0), bone, 2.0)
			for i in 4:
				var x := (-8 + i * 3) * k
				ci.draw_arc(Vector2(x, 2 * k), 2.5 * k, PI * 0.1, PI * 0.9, 6, bone, 1.0)
			# Schwanz
			var w := sin(t * 8.0) * 2.0
			ci.draw_line(Vector2(-10 * k, 1 * k), Vector2(-14 * k, -4 * k + w), bone, 1.5)
			# Schädel
			var h := Vector2(8 * k, -4 * k + bob)
			ci.draw_circle(h, 4.5 * k, bone)
			ci.draw_rect(Rect2(h + Vector2(2 * k, -1), Vector2(5 * k, 4 * k)), bone)
			_poly(ci, [h + Vector2(-4, -3 * k), h + Vector2(-2, -9 * k), h + Vector2(0, -3 * k)], bone)
			ci.draw_circle(h + Vector2(0.5, -0.5), 1.8 * k, dark)
			_eyes(ci, h + Vector2(0.5, -0.5), h + Vector2(0.5, -0.5), Color("e04040"), 0.7 * k)
			ci.draw_line(h + Vector2(3 * k, 2.5 * k), h + Vector2(7 * k, 2.5 * k), dark, 1.0)
		"irrlicht", "seelenflamme":
			var big := species == "seelenflamme"
			var k := 1.4 if big else 1.0
			var outer := Color("e8682e") if not big else Color("7a4ad8")
			var inner := Color("f8c858") if not big else Color("b8a0ff")
			var fl := sin(t * 12.0)
			ci.draw_circle(Vector2(0, -2 + bob), 12 * k, Color(outer, 0.12))
			_poly(ci, [Vector2(-7 * k, 0 + bob), Vector2(-3 * k, -10 * k + fl + bob), Vector2(0, -16 * k - fl + bob), Vector2(3 * k, -10 * k + bob), Vector2(7 * k, 0 + bob)], outer)
			ci.draw_circle(Vector2(0, 0 + bob), 7 * k, outer)
			ci.draw_circle(Vector2(0, 1 + bob), 4.5 * k, inner)
			if big:
				ci.draw_circle(Vector2(0, 0 + bob), 3, Color("e8e0ff"))
			_eyes(ci, Vector2(-2.2 * k, -1 + bob), Vector2(2.2 * k, -1 + bob), Color("1a0a10"), 1.0)
		"blutegel":
			var col := Color("7a1a24")
			for i in 5:
				var x := -9 + i * 4.5
				var y := 5 + sin(t * 4.0 + i) * 1.5
				ci.draw_circle(Vector2(x, y), 4.0 - abs(i - 2) * 0.4, col if i % 2 else Color("8e2430"))
			ci.draw_circle(Vector2(10, 3), 4.5, Color("9a2a36"))
			ci.draw_circle(Vector2(12, 3), 2.2, Color("1a0508"))
			for i in 6:
				var a := TAU * i / 6.0
				ci.draw_line(Vector2(12, 3) + Vector2(cos(a), sin(a)) * 1.5, Vector2(12, 3) + Vector2(cos(a), sin(a)) * 2.5, Color("e0d0c0"), 0.8)
			_eyes(ci, Vector2(8, 0), Vector2(10, -0.5), Color("f0e0a0"), 0.6)
		"kraehenbalg":
			var col := Color("16121c")
			var f := sin(t * 6.0) * 3.0
			ci.draw_circle(Vector2(0, -2 + bob), 13, Color(0.4, 0.9, 0.85, 0.08))
			_poly(ci, [Vector2(-3, -2 + bob), Vector2(-14, -8 + f + bob), Vector2(-9, 2 + bob)], col)
			_poly(ci, [Vector2(-8, 4 + bob), Vector2(-14, 8 + bob), Vector2(-6, 6 + bob)], col)
			ci.draw_circle(Vector2(0, 1 + bob), 6, col)
			ci.draw_circle(Vector2(5, -5 + bob), 4, col)
			_poly(ci, [Vector2(8, -6 + bob), Vector2(14, -4 + bob), Vector2(8, -3 + bob)], Color("c8b070"))
			ci.draw_line(Vector2(-1, 7 + bob), Vector2(-2, 10), Color("c8b070"), 1.0)
			ci.draw_line(Vector2(2, 7 + bob), Vector2(3, 10), Color("c8b070"), 1.0)
			_eyes(ci, Vector2(6, -6 + bob), Vector2(6, -6 + bob), Color("6af0e0"), 1.0)
		_:
			ci.draw_circle(Vector2(0, 0), 8, Color.MAGENTA)
