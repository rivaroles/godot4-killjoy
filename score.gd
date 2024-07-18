extends Label

var score = 0

func _on_score_collect():
	score += 1
	text = 'Score: %s' % score
