extends Node

signal max_health_changed(new_value)
signal health_changed(new_value)
signal score_changed(new_value)
signal equip_changed(new_texture)

var max_health: int = 5 setget set_maxhealth
var health: int = 5 setget set_health
var score: int = 0 setget set_score

var equip_texture: Texture = null setget set_equip
var player_path: NodePath setget set_playerpath
var player: Node2D = null setget ,get_player


func set_health(value: int):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", health)


func set_maxhealth(value: int):
	var diff: int = value - max_health
	max_health = max(1, value)
	if health:
		self.health = health + diff if diff > 0 else health
	emit_signal("max_health_changed", max_health)


func set_score(value: int):
	score = max(0, value)
	emit_signal("score_changed", score)


func set_equip(value: Texture):
	equip_texture = value
	emit_signal("equip_changed", value)


func set_playerpath(value: NodePath):
	player_path = value
	if value:
		player = get_node_or_null(player_path)


func get_player():
	return player


func _on_player_dead():
	# save player score
	print("Saving")
	var file = File.new()
	var scores: Array = []
	if file.file_exists(Options.HIGHSCORE_FILE):
		file.open(Options.HIGHSCORE_FILE, file.READ)
		var json = JSON.parse(file.get_as_text())
		if json.error != 0:
			push_warning("Error loading highscores")
		scores = json.result as Array
		file.close()
	scores.push_back({"name": Options.player_name, "score": score, "date": OS.get_date()})
	file.open(Options.HIGHSCORE_FILE, file.WRITE)
	file.store_line(to_json(scores))
	file.close()
