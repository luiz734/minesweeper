extends "res://scripts/Mine.gd"


func play_end_match_animation(victory: bool):
	_background = BACKGROUND_VICTORY if victory else BACKGROUND_LOSE
	print("Overwrited")
	update_textures()
