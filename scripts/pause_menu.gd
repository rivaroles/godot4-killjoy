extends Control

func _on_resume_button_pressed():
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_quit_button_pressed():
	get_tree().quit()
