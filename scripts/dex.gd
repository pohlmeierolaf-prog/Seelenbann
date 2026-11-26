class_name Dex
extends RefCounted
## Alle Spieldaten zu Elementen, Kreaturen und Attacken.

## Element -> Elemente, gegen die es stark ist (×2). Umgekehrt ×0,5.
const STRONG := {
	"Schatten": ["Höllenfeuer", "Geist"],
	"Knochen": ["Schatten", "Blut"],
	"Höllenfeuer": ["Knochen", "Frost", "Fäulnis"],
	"Blut": ["Geist", "Heilig"],
	"Fäulnis": ["Blut", "Knochen"],
	"Frost": ["Blut", "Fäulnis"],
	"Geist": ["Knochen", "Frost"],
	"Heilig": ["Schatten", "Fäulnis", "Geist"],
}

const COLORS := {
	"Schatten": Color("9a78c0"), "Knochen": Color("d8cfb0"), "Höllenfeuer": Color("e8682e"),
	"Blut": Color("d03040"), "Fäulnis": Color("8aaa3a"), "Frost": Color("8ac0e0"),
	"Geist": Color("6ad8c8"), "Heilig": Color("f0e090"),
}

## Basiswerte: hp, atk, def, spd. learn: [Level, Attacke]. evolve: [Level, Ziel].
const SPECIES := {
	"grabmotte": {"name": "Grabmotte", "element": "Schatten", "base": [45, 50, 40, 65], "xp": 50,
		"learn": [[1, "schattenstaub"], [1, "fluegelschlag"], [7, "finsterflug"]], "evolve": [12, "totenfalter"]},
	"totenfalter": {"name": "Totenfalter", "element": "Schatten", "base": [70, 80, 60, 95], "xp": 140,
		"learn": [[1, "schattenstaub"], [1, "finsterflug"], [16, "seelenschrei"]]},
	"knochenwelpe": {"name": "Knochenwelpe", "element": "Knochen", "base": [50, 60, 50, 50], "xp": 55,
		"learn": [[1, "knochenbiss"], [1, "grabesheulen"], [4, "schattenstaub"], [8, "knochensplitter"]], "evolve": [12, "gruftwolf"]},
	"gruftwolf": {"name": "Gruftwolf", "element": "Knochen", "base": [80, 95, 75, 75], "xp": 150,
		"learn": [[1, "knochenbiss"], [1, "knochensplitter"], [16, "aderlass"]]},
	"irrlicht": {"name": "Irrlicht", "element": "Höllenfeuer", "base": [40, 65, 40, 60], "xp": 50,
		"learn": [[1, "glutfunke"], [1, "schattenstaub"], [8, "hoellenglut"]], "evolve": [12, "seelenflamme"]},
	"seelenflamme": {"name": "Seelenflamme", "element": "Höllenfeuer", "base": [65, 100, 60, 85], "xp": 145,
		"learn": [[1, "glutfunke"], [1, "hoellenglut"], [16, "seelenschrei"]]},
	"blutegel": {"name": "Blutegel", "element": "Blut", "base": [55, 45, 50, 35], "xp": 45,
		"learn": [[1, "blutsauger"], [6, "aderlass"]]},
	"kraehenbalg": {"name": "Krähenbalg", "element": "Geist", "base": [40, 55, 35, 70], "xp": 48,
		"learn": [[1, "geisterkralle"], [1, "fluegelschlag"], [7, "seelenschrei"]]},
}

## power 0 = Statuswirkung. effect: "drain" (heilt 50 % des Schadens), "atk_up".
const MOVES := {
	"knochenbiss": {"name": "Knochenbiss", "element": "Knochen", "power": 45, "acc": 100},
	"knochensplitter": {"name": "Knochensplitter", "element": "Knochen", "power": 70, "acc": 90},
	"grabesheulen": {"name": "Grabesheulen", "element": "Knochen", "power": 0, "acc": 100, "effect": "atk_up"},
	"schattenstaub": {"name": "Schattenstaub", "element": "Schatten", "power": 40, "acc": 100},
	"finsterflug": {"name": "Finsterflug", "element": "Schatten", "power": 65, "acc": 95},
	"fluegelschlag": {"name": "Flügelschlag", "element": "Geist", "power": 35, "acc": 100},
	"glutfunke": {"name": "Glutfunke", "element": "Höllenfeuer", "power": 40, "acc": 100},
	"hoellenglut": {"name": "Höllenglut", "element": "Höllenfeuer", "power": 70, "acc": 90},
	"blutsauger": {"name": "Blutsauger", "element": "Blut", "power": 40, "acc": 100, "effect": "drain"},
	"aderlass": {"name": "Aderlass", "element": "Blut", "power": 65, "acc": 95},
	"geisterkralle": {"name": "Geisterkralle", "element": "Geist", "power": 40, "acc": 100},
	"seelenschrei": {"name": "Seelenschrei", "element": "Geist", "power": 70, "acc": 90},
}

## Wilde Kreaturen im Grabmoos: [Art, min. Level, max. Level, Gewicht]
const ENCOUNTERS := {
	"friedhof": [["blutegel", 2, 4, 35], ["kraehenbalg", 2, 4, 25], ["grabmotte", 3, 5, 15],
		["knochenwelpe", 3, 5, 10], ["irrlicht", 3, 5, 15]],
}


static func effectiveness(attack: String, target: String) -> float:
	if target in STRONG.get(attack, []):
		return 2.0
	if attack in STRONG.get(target, []):
		return 0.5
	return 1.0


static func _stat(base: int, level: int) -> int:
	return int(base * 2 * level / 100.0) + 5


## Erzeugt eine Kreatur als Dictionary (lässt sich später direkt speichern).
static func make(species: String, level: int) -> Dictionary:
	var mon := {"species": species, "level": level, "xp": 0}
	recalc(mon)
	mon["hp"] = mon["max_hp"]
	var moves: Array = []
	for entry in SPECIES[species]["learn"]:
		if entry[0] <= level and not entry[1] in moves:
			moves.append(entry[1])
	mon["moves"] = moves.slice(-4)
	return mon


static func recalc(mon: Dictionary) -> void:
	var b: Array = SPECIES[mon["species"]]["base"]
	var lv: int = mon["level"]
	mon["max_hp"] = int(b[0] * 2 * lv / 100.0) + lv + 10
	mon["atk"] = _stat(b[1], lv)
	mon["def"] = _stat(b[2], lv)
	mon["spd"] = _stat(b[3], lv)


static func name_of(mon: Dictionary) -> String:
	return SPECIES[mon["species"]]["name"]


static func element_of(mon: Dictionary) -> String:
	return SPECIES[mon["species"]]["element"]


static func random_encounter(map_id: String) -> Dictionary:
	var table: Array = ENCOUNTERS.get(map_id, [])
	var total := 0
	for e in table:
		total += e[3]
	var roll := randi() % total
	for e in table:
		roll -= e[3]
		if roll < 0:
			return make(e[0], randi_range(e[1], e[2]))
	return make(table[0][0], table[0][1])
