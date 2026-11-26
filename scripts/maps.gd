class_name Maps
extends RefCounted
## Alle Karten als Text. Legende:
##  .  Gras            "  Grabmoos (hier lauern Kreaturen)   =  Weg
##  #  Mauer           T  toter Baum      +  Grabstein          ~  Sumpf
##  R  Dach            H  Hauswand        D  Tür                S  Schild
##  L  Laterne         f  Zaun            B  Brunnen            C  Gruft
##  G  Tor (Übergang zu einer anderen Karte)

const MAPS := {
	"rabenstein": {
		"name": "Rabenstein",
		"encounters": false,
		"rows": [
			"##############GG################",
			"#TTT.....T...L==L...T.....TTTTT#",
			"#TT..RRRRR....==....RRRRRR...TT#",
			"#T...RRRRR....==....RRRRRR....T#",
			"#....HHDHH....==....HHHDHH.....#",
			"#......=......==.......=.......#",
			"#......================.......f#",
			"#..S.........====.............f#",
			"#....L.......=BB=......L......f#",
			"#............=BB=.............f#",
			'#T...........====........."""""#',
			'#TT...........==.........."""""#',
			'#~~~..........==......RRRRR."""#',
			"#~~~~.........==......RRRRR...T#",
			"#~~~..+.+.....==......HHDHH...T#",
			"#T.....+......==........=.....T#",
			"#TT...........===========.....T#",
			"#TTT..T.......==..........T..TT#",
			"#TTTTTTTT...TT==TTT....TTTTTTTT#",
			"################################",
		],
		"warps": {
			Vector2i(14, 0): {"map": "friedhof", "pos": Vector2i(14, 16), "dir": Vector2i.UP},
			Vector2i(15, 0): {"map": "friedhof", "pos": Vector2i(15, 16), "dir": Vector2i.UP},
		},
		"actions": {Vector2i(24, 14): "heal"},
		"signs": {
			Vector2i(3, 7): ["Rabenstein.", "Letzte Zuflucht vor dem Friedhof der Vergessenen."],
			Vector2i(7, 4): ["Die Tür ist verriegelt.", "Von drinnen hört man leises Beten."],
			Vector2i(23, 4): ["Ein Schild: »Morwen – Seelensteine & Tränke«", "Heute geschlossen."],
			Vector2i(14, 8): ["Ein alter Brunnen.", "Tief unten flüstert etwas deinen Namen..."],
			Vector2i(15, 8): ["Ein alter Brunnen.", "Tief unten flüstert etwas deinen Namen..."],
			Vector2i(14, 9): ["Das Wasser ist schwarz wie Tinte."],
			Vector2i(15, 9): ["Das Wasser ist schwarz wie Tinte."],
			Vector2i(6, 14): ["Hier ruht Aldric. Er wollte nicht bannen."],
			Vector2i(8, 14): ["Hier ruht Mira. Gebannt, geliebt, vergessen."],
			Vector2i(7, 15): ["Der Name ist unleserlich."],
		},
	},
	"friedhof": {
		"name": "Friedhof der Vergessenen",
		"encounters": true,
		"rows": [
			"################################",
			"#TT#####......CC......#####TTTT#",
			"#T.#+.+#.....=CC=.....#+.+#..TT#",
			"#..#...#.....====.....#...#...T#",
			"#..##.##......==......##.##....#",
			'#"""...L......==......L..."""""#',
			'#"""""........==........"""""""#',
			'#""+""".+.+...==...+.+.""+"""""#',
			'#"""""........==........""""""T#',
			'#T.....+.+.+..==..+.+.+.....""T#',
			'#TT...........==...........""""#',
			'#~~~..."""""""=="""""".......""#',
			'#~~~~..""+""""==""+"""...T.....#',
			'#~~~..."""""""=="""""".........#',
			"#T..........S.==.............TT#",
			"#TT...+.+.+...==...+.+.+....TTT#",
			"#TTTTT........==.........TTTTTT#",
			"##############GG################",
		],
		"warps": {
			Vector2i(14, 17): {"map": "rabenstein", "pos": Vector2i(14, 1), "dir": Vector2i.DOWN},
			Vector2i(15, 17): {"map": "rabenstein", "pos": Vector2i(15, 1), "dir": Vector2i.DOWN},
		},
		"signs": {
			Vector2i(12, 14): ["Friedhof der Vergessenen.", "Wer hier im Grabmoos wandelt, wird nicht allein sein."],
			Vector2i(14, 1): ["Die Gruft ist versiegelt.", "Ein kalter Atem dringt durch die Ritzen."],
			Vector2i(15, 1): ["Die Gruft ist versiegelt.", "Ein kalter Atem dringt durch die Ritzen."],
			Vector2i(14, 2): ["Die Gruft ist versiegelt.", "Ein kalter Atem dringt durch die Ritzen."],
			Vector2i(15, 2): ["Die Gruft ist versiegelt.", "Ein kalter Atem dringt durch die Ritzen."],
		},
	},
}
