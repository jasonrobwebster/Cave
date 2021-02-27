extends GridContainer

const MAX_HIGHSCORE_LENGTH := 13

var nb_scores: int = 0


func _ready():
	nb_scores = get_child_count() / 2
	_load_highscores()


func _load_highscores():
	var file = File.new()
	if not file.file_exists(Options.HIGHSCORE_FILE):
		return
	file.open(Options.HIGHSCORE_FILE, file.READ)
	var json = JSON.parse(file.get_as_text())
	if json.error != 0:
		push_warning("Scores not loading correctly")
		return
	var scores: Array = json.result as Array
	scores.sort_custom(self, "_sort_scores")
	for i in range(min(nb_scores, len(scores))):
		get_child(i*2).text = scores[i]["name"].left(6)
		get_child(i*2 + 1).text = str(scores[i]["score"])


func _sort_scores(a: Dictionary, b: Dictionary):
	return a["score"] > b["score"]


func _construct_score_string(data: Dictionary, replace: String):
	var name: String = data["name"]
	var score: String = str(data["score"])
	if len(score) + len(name) >= MAX_HIGHSCORE_LENGTH:
		name = name.left(MAX_HIGHSCORE_LENGTH - len(score) - 3)
		return name + " ".repeat(MAX_HIGHSCORE_LENGTH - len(name) - len(score)) + score
	var out = replace.left(len(name))
	out = out.right(len(out) - len(score) - 2)
	return name + out + score
	
