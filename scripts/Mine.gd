extends TextureRect

signal cell_clicked

onready var mine_texture_rect = $margin/mine

const MINE_SPRITE = preload("res://sprites/default/mine1.png")
const FLAG_SPRITE = preload("res://sprites/default/flag1.png")
const BACKGROUND_FLAGGED = preload("res://sprites/neon2/bg-blue.png")
const BACKGROUND_SHOW = preload("res://sprites/neon2/bg-purple-dark.png")
const BACKGROUND_HIDDEN = preload("res://sprites/neon2/bg-purple-bright.png")
const BACKGROUND_LOSE = preload("res://sprites/neon2/bg-red.png")
const BACKGROUND_VICTORY = preload("res://sprites/neon2/bg-green.png")

var value
var index
var _is_flagged = false #setget set_flagged, get_flagged
var _is_hidden = true #setget set_hidden, get_hidden


var _mine = null
var _background = BACKGROUND_HIDDEN


func _on_background_gui_input(event):
	if event.is_action_pressed("click_left") and not _is_flagged and _is_hidden:
		emit_signal("cell_clicked", index, true)
		
	elif event.is_action_pressed("click_right") and _is_hidden:
		emit_signal("cell_clicked", index, false)


func toggle_mine_flag() -> bool:	
	_is_flagged = not _is_flagged
	update_textures()
	
	return _is_flagged


func init(_value: int, _index: int):
	value = _value 
	index = _index
	
	if value != 0:
		_mine = MINE_SPRITE if value == -1 else load("res://sprites/default/num" + str(value) + ".png")
	
	_background = BACKGROUND_HIDDEN

	assert(connect("cell_clicked", get_node("/root/background/mainHBox/gameArea"), 
	"handle_player_action") == OK)
	
	update_textures()


func set_flagged(new_value: bool) ->bool:
	_is_flagged = new_value
	return _is_flagged

func get_flagged() -> bool:
	return _is_flagged

func set_hidden(new_value: bool) -> bool:
	_is_hidden = new_value
	
	if value == -1:
		pass
		
	_background = BACKGROUND_SHOW if not _is_hidden else BACKGROUND_HIDDEN	
	update_textures()
	return _is_hidden
	
	
func get_hidden() -> bool:
	return _is_hidden


func update_textures():
	mine_texture_rect.visible = not _is_hidden or _is_flagged
	
	if _is_flagged:
		texture = BACKGROUND_FLAGGED
		mine_texture_rect.texture = FLAG_SPRITE
	else:
		texture = _background
		mine_texture_rect.texture = _mine


func play_end_match_animation(victory: bool):
	set_flagged(false)
	set_hidden(false)
	_background = BACKGROUND_FLAGGED if victory else BACKGROUND_FLAGGED
	update_textures()
