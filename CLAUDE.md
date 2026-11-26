# Seelenbann – Projektnotizen für Claude

Düsteres, gotisches 2D-Monsterbann-RPG (Godot 4.4.1, GDScript). Sprache im Spiel und in der Doku: Deutsch.
Eigenes Spiel – keine Namen, Figuren, Grafiken oder Welten aus bestehenden Spielen übernehmen.

## Design-Entscheidungen
- Nur Kreaturen kämpfen, rundenbasiert. Stärker werden durch Leveln, Entwicklung und Ausrüstung (zufällige Werte, Seltenheiten).
- Ansicht 2D von oben, Kachel-für-Kachel-Bewegung, Querformat. Basisauflösung 384×216, 16-px-Kacheln.
- Ziel: Browser (GitHub Pages, Single-Thread-Web-Export). Android-APK später aus demselben Code.
- Elemente (stark gegen): Schatten→Höllenfeuer,Geist · Knochen→Schatten,Blut · Höllenfeuer→Knochen,Frost,Fäulnis ·
  Blut→Geist,Heilig · Fäulnis→Blut,Knochen · Frost→Blut,Fäulnis · Geist→Knochen,Frost · Heilig→Schatten,Fäulnis,Geist. ×2 / ×0,5.
- Testversion: 8 Kreaturen. Grabmotte→Totenfalter (Schatten), Knochenwelpe→Gruftwolf (Knochen),
  Irrlicht→Seelenflamme (Höllenfeuer), Blutegel (Blut), Krähenbalg (Geist).

## Meilensteine
1. ✅ Gerüst, Dorf Rabenstein + Friedhof, Laufen, Touch-Steuerung, Schilder/Dialoge, Web-Deploy
2. ✅ Rundenkampf (Zufallsbegegnungen im Grabmoos `"`), Heilen an der Haustür, Niederlage → zurück nach Hause
3. Bannen mit Seelensteinen (Menüpunkt existiert schon), Leveln (XP wird bereits in `mon.xp` gesammelt), Entwicklung (`evolve` in Dex), Team, Starterwahl
4. Ausrüstung & Beute, Speichern
5. Gruft mit Boss, Feinschliff

## Arbeitsweise (Volumen sparen – Nutzer hat begrenztes Budget)
- Ein Meilenstein pro Sitzung, danach committen und stoppen.
- Grafik nur per Code (`_draw`), keine Asset-Pipelines. Inhalte (Karten, später Kreaturen/Attacken) als Daten in `scripts/*.gd`.
- Prüfen: `godot --headless --import`, dann Web-Export + kurzer Playwright-Test – sparsam mit Screenshots.
  Test-Abkürzung: `index.html#kampf` startet nach dem Titel direkt einen Kampf.

## Aufbau
- `scripts/main.gd` – baut Szene, Eingaben, UI, Kartenwechsel
- `scripts/maps.gd` – Karten als Text (Legende im Kopf), Schilder, Übergänge
- `scripts/world_map.gd` – Zeichnen + Begehbarkeit · `scripts/player.gd` – Held
- `scripts/touch_controls.gd`, `scripts/dialog_box.gd`
- `scripts/dex.gd` – Elemente, Kreaturen, Attacken, Begegnungstabellen (Kreatur = Dictionary)
- `scripts/battle.gd` – Kampfablauf + Kampfbildschirm · `scripts/creature_art.gd` – Kreaturen per Code gezeichnet
