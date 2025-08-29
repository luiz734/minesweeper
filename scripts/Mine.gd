extends TextureRect

signal cell_clicked

@onready var mine_texture_rect = %MineSprite
@onready var label: Label = %Label

const MINE_SPRITE = preload("res://sprites/newui/mine.png")
const FLAG_SPRITE = preload("res://sprites/newui/flag.png")

const BACKGROUND_FLAGGED = preload("res://sprites/newui/bg-flag.png")
const BACKGROUND_SHOW = preload("res://sprites/newui/bg-show.png")
const BACKGROUND_HIDDEN = preload("res://sprites/newui/bg-hidden.png")
const BACKGROUND_LOSE = preload("res://sprites/newui/bg-red.png")
const BACKGROUND_VICTORY = preload("res://sprites/newui/bg-green.png")

var value
var index
var _is_flagged = false
var _is_hidden = true
var _mouse_in = false


func _ready() -> void:
    mouse_entered.connect(func(): _mouse_in = true)
    mouse_exited.connect(func(): _mouse_in = false)

func _input(event: InputEvent) -> void:
    if not _mouse_in:
        return

    if event.is_action_pressed("click_left") and not _is_flagged and _is_hidden:
        cell_clicked.emit(index, true)

    elif event.is_action_pressed("click_right") and _is_hidden:
         cell_clicked.emit(index, false)

func toggle_mine_flag():
    _is_flagged = not _is_flagged

    if _is_flagged:
        mine_texture_rect.texture = FLAG_SPRITE
        texture = BACKGROUND_FLAGGED
    else:
        mine_texture_rect.texture = null
        texture = BACKGROUND_HIDDEN


func init(_value: int, _index: int):
    value = _value
    index = _index
    label.text = str(value)

func set_flagged(new_value: bool):
    _is_flagged = new_value
    if new_value:
        mine_texture_rect.texture = BACKGROUND_FLAGGED

func get_flagged() -> bool:
    return _is_flagged

func set_hidden(new_value: bool):
    _is_hidden = new_value
    label.visible = not new_value and value > 0
    texture = BACKGROUND_SHOW if not _is_hidden else BACKGROUND_HIDDEN

    # Handle mines
    if value == -1:
        texture = BACKGROUND_LOSE
        mine_texture_rect.texture = MINE_SPRITE

func reset_to_default():
    set_flagged(false)
    set_hidden(true)
    mine_texture_rect.texture = null
    texture = BACKGROUND_HIDDEN


func get_hidden() -> bool:
    return _is_hidden


func play_end_match_animation(victory: bool):
    set_flagged(false)
    set_hidden(false)
    if value != -1:
        mine_texture_rect.texture = null
