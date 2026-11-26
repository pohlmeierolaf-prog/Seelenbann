class_name WorldMap
extends Node2D
## Zeichnet eine Kachelkarte aus Maps.MAPS (Platzhalter-Grafik, rein per Code).

const TILE := 16
const WALKABLE := ".\"=G"

var rows: Array = []
var width := 0
var height := 0
var data: Dictionary = {}
var map_name := ""
var encounters := false


func load_map(id: String) -> void:
	data = Maps.MAPS[id]
	rows = data["rows"]
	map_name = data["name"]
	encounters = data.get("encounters", false)
	height = rows.size()
	width = 0
	for r in rows:
		width = max(width, r.length())
	queue_redraw()


func tile_at(c: Vector2i) -> String:
	if c.y < 0 or c.y >= height or c.x < 0:
		return "#"
	var r: String = rows[c.y]
	if c.x >= r.length():
		return "#"
	return r[c.x]


func is_walkable(c: Vector2i) -> bool:
	return WALKABLE.contains(tile_at(c))


func get_sign(c: Vector2i):
	return data.get("signs", {}).get(c, null)


func get_warp(c: Vector2i):
	return data.get("warps", {}).get(c, null)


# --- Zeichnen ---------------------------------------------------------------

func _h(x: int, y: int) -> int:
	return absi((x * 73856093) ^ (y * 19349663) ^ 0x5bd1e995) % 1000


func _draw() -> void:
	draw_rect(Rect2(-400, -400, width * TILE + 800, height * TILE + 800), Color("07060a"))
	var glows: Array = []
	for y in height:
		for x in width:
			var c := tile_at(Vector2i(x, y))
			_draw_tile(c, x, y)
			if c == "L":
				glows.append(Vector2(x * TILE + 8, y * TILE + 4))
	for g in glows:
		draw_circle(g, 26, Color(1.0, 0.65, 0.25, 0.06))
		draw_circle(g, 16, Color(1.0, 0.7, 0.3, 0.08))
		draw_circle(g, 8, Color(1.0, 0.75, 0.35, 0.12))


func _grass(p: Vector2, x: int, y: int) -> void:
	var h := _h(x, y)
	draw_rect(Rect2(p, Vector2(TILE, TILE)), Color("29311f") if h % 2 == 0 else Color("262d1d"))
	if h % 3 == 0:
		draw_rect(Rect2(p + Vector2(3 + h % 7, 4 + h % 5), Vector2(1, 2)), Color("3a4529"))
	if h % 5 == 0:
		draw_rect(Rect2(p + Vector2(10 - h % 4, 10 + h % 3), Vector2(1, 2)), Color("1b2115"))


func _path(p: Vector2, x: int, y: int) -> void:
	draw_rect(Rect2(p, Vector2(TILE, TILE)), Color("3e3a44"))
	var o := (y % 2) * 4
	for i in 2:
		for j in 2:
			var r := Rect2(p + Vector2(j * 8 + o % 8, i * 8) + Vector2(1, 1), Vector2(6, 6))
			r = r.intersection(Rect2(p, Vector2(TILE, TILE)))
			draw_rect(r, Color("4a4652") if (_h(x * 2 + j, y * 2 + i) % 3) else Color("45414c"))


func _draw_tile(c: String, x: int, y: int) -> void:
	var p := Vector2(x * TILE, y * TILE)
	var full := Rect2(p, Vector2(TILE, TILE))
	match c:
		".":
			_grass(p, x, y)
		"\"":
			draw_rect(full, Color("1f2818"))
			var h := _h(x, y)
			for i in 4:
				var bx := p.x + 2 + i * 4 + (h >> i) % 2
				draw_line(Vector2(bx, p.y + 15), Vector2(bx - 1 + (i % 2) * 2, p.y + 5 + (h + i) % 4), Color("3c4d2c"), 1.0)
				draw_line(Vector2(bx + 2, p.y + 15), Vector2(bx + 2, p.y + 9 + (h + i) % 3), Color("2c3a20"), 1.0)
		"=":
			_path(p, x, y)
		"G":
			_path(p, x, y)
			draw_rect(full, Color(0, 0, 0, 0.35))
		"#":
			draw_rect(full, Color("302c37"))
			draw_rect(Rect2(p, Vector2(TILE, 2)), Color("433e4b"))
			draw_line(p + Vector2(0, 8), p + Vector2(16, 8), Color("221f28"))
			draw_line(p + Vector2(4 + (y % 2) * 8, 2), p + Vector2(4 + (y % 2) * 8, 8), Color("221f28"))
			draw_line(p + Vector2(12 - (y % 2) * 8, 8), p + Vector2(12 - (y % 2) * 8, 16), Color("221f28"))
		"T":
			_grass(p, x, y)
			draw_circle(p + Vector2(8, 14), 5, Color(0, 0, 0, 0.3))
			draw_rect(Rect2(p + Vector2(6, 6), Vector2(4, 9)), Color("2a2019"))
			var col := Color("33261d")
			draw_line(p + Vector2(8, 7), p + Vector2(2, 1), col, 2.0)
			draw_line(p + Vector2(8, 6), p + Vector2(14, 0), col, 2.0)
			draw_line(p + Vector2(8, 5), p + Vector2(9, -2), col, 1.5)
			draw_line(p + Vector2(4, 3), p + Vector2(3, -1), col, 1.0)
			draw_line(p + Vector2(12, 2), p + Vector2(15, 3), col, 1.0)
		"+":
			_grass(p, x, y)
			draw_rect(Rect2(p + Vector2(3, 13), Vector2(10, 2)), Color(0, 0, 0, 0.35))
			draw_rect(Rect2(p + Vector2(4, 6), Vector2(8, 8)), Color("5f5c68"))
			draw_circle(p + Vector2(8, 6), 4, Color("5f5c68"))
			draw_line(p + Vector2(8, 4), p + Vector2(8, 11), Color("34323b"))
			draw_line(p + Vector2(6, 6), p + Vector2(10, 6), Color("34323b"))
		"R":
			draw_rect(full, Color("4a1d23"))
			for i in 4:
				draw_line(p + Vector2(0, i * 4 + 3), p + Vector2(16, i * 4 + 3), Color("34121a"))
		"H", "D":
			draw_rect(full, Color("3b2d29"))
			draw_rect(Rect2(p, Vector2(TILE, 2)), Color("241917"))
			draw_line(p + Vector2(0, 15), p + Vector2(16, 15), Color("241917"))
			if c == "D":
				draw_rect(Rect2(p + Vector2(4, 5), Vector2(8, 11)), Color("1e130d"))
				draw_circle(p + Vector2(8, 5), 4, Color("1e130d"))
				draw_rect(Rect2(p + Vector2(10, 10), Vector2(1, 1)), Color("b08a40"))
			elif _h(x, y) % 2 == 0:
				draw_rect(Rect2(p + Vector2(5, 5), Vector2(6, 6)), Color("1a1210"))
				draw_rect(Rect2(p + Vector2(6, 6), Vector2(4, 4)), Color("8a6a30"))
		"~":
			draw_rect(full, Color("141f26"))
			var h := _h(x, y)
			draw_line(p + Vector2(2 + h % 4, 5), p + Vector2(7 + h % 4, 5), Color("23343f"))
			draw_line(p + Vector2(8 - h % 3, 11), p + Vector2(14 - h % 3, 11), Color("23343f"))
		"S":
			_grass(p, x, y)
			draw_rect(Rect2(p + Vector2(7, 8), Vector2(2, 7)), Color("3a2a1e"))
			draw_rect(Rect2(p + Vector2(2, 3), Vector2(12, 7)), Color("5a4030"))
			draw_line(p + Vector2(4, 6), p + Vector2(12, 6), Color("3a2a1e"))
		"L":
			_grass(p, x, y)
			draw_rect(Rect2(p + Vector2(7, 4), Vector2(2, 11)), Color("1c1a20"))
			draw_rect(Rect2(p + Vector2(5, 1), Vector2(6, 5)), Color("1c1a20"))
			draw_rect(Rect2(p + Vector2(6, 2), Vector2(4, 3)), Color("e8b858"))
		"f":
			_grass(p, x, y)
			draw_rect(Rect2(p + Vector2(0, 6), Vector2(16, 2)), Color("2e2620"))
			draw_rect(Rect2(p + Vector2(0, 11), Vector2(16, 2)), Color("2e2620"))
			draw_rect(Rect2(p + Vector2(7, 3), Vector2(2, 12)), Color("3a3028"))
		"B":
			draw_rect(full, Color("4a4652"))
			draw_rect(Rect2(p + Vector2(2, 2), Vector2(12, 12)), Color("0a1014"))
			draw_rect(Rect2(p + Vector2(0, 0), Vector2(16, 1)), Color("5a5662"))
		"C":
			draw_rect(full, Color("26232c"))
			draw_rect(Rect2(p + Vector2(1, 4), Vector2(14, 12)), Color("050407"))
			draw_rect(Rect2(p, Vector2(TILE, 3)), Color("3a3642"))
		_:
			draw_rect(full, Color("07060a"))
