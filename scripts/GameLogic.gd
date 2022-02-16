extends MarginContainer

signal player_won
signal player_lost
signal game_started
signal game_finished
signal new_match_created

export(int) var size = 9
export(int) var bombs_amount = 10

var Mine = preload("res://scenes/mine.tscn")
var MineBomb = preload("res://scenes/MineBomb.tscn")
var Grid = load("res://scripts/GameGenerator.gd")

onready var rowList = $rowList 
onready var timer = $"../menuArea/background/margin/buttons/timeMargin/timeLabel"
onready var UI_controler = get_tree().get_root()


# TODO: change from "mines" to "cells"
var _grid_instance = Grid.new()
var _grid = []
var _mines = []
var _discovered_cells = 0
var _first_action_played = false
var _input_allowed = true

func _ready():
	assert(connect("game_started", timer, "start") == OK)
	assert(connect("game_finished", timer, "stop") == OK)
	assert(connect("new_match_created", timer, "clear") == OK)
	
	newGame()


func _generate_UI_components():
	for row in range(size):
		var new_row = HBoxContainer.new()
		new_row.size_flags_horizontal = SIZE_EXPAND_FILL
		new_row.size_flags_vertical = SIZE_EXPAND_FILL
		new_row.set_name("row-" + str(row))
		new_row.set("custom_constants/separation", -5)
		rowList.add_child(new_row)
		

		for i in range(size):
			var new_mine
			if _grid[row * size + i] == -1:
				new_mine = MineBomb.instance()
			else:
				new_mine = Mine.instance()
				
			_mines.push_back(new_mine)
			new_row.add_child(new_mine)
			new_mine.set_name("mine-" + str(i))
			new_mine.set_hidden(true)
		

func _init_mines():
	for i in range(size * size):
		_mines[i].init(_grid[i], i)


func handle_player_action(index: int, was_left_click: bool) -> void:
	# TODO: refactor this mess
	if _input_allowed:
		if was_left_click:
			if not _first_action_played:
				_first_action_played = true
				emit_signal("game_started")
			
			if _mines[index].value == -1:
				_mines[index].set_hidden(false)
				_input_allowed = false
				emit_signal("game_finished")
				emit_signal("player_won")
			else:	
				reveal_value(index)
		else:
			_mines[index].toggle_mine_flag()


func _is_index_valid(row, col):
	if row < 0 or row >= size or col < 0 or col >= size:
		return false
	return true


func reveal_value(index):
	if not _mines[index].get_hidden():
		return
	
	_mines[index].set_hidden(false)
	_discovered_cells += 1
	if _discovered_cells == (size * size) - bombs_amount:
		print("GANHOU")
		_input_allowed = false
		emit_signal("game_finished")
		emit_signal("player_won")
		
	
	var row: int = index / size
	var col: int = index % size
	
	if _mines[index].value == 0:
		for i in range(-1, 2):
			for j in range(-1, 2):
				var ajacent_mine_idx = (row + i) * size + (col + j)
				if _is_index_valid(row + i, col + j):
					reveal_value(ajacent_mine_idx)


func resetGame():
	for mine in _mines:
		mine.set_flagged(false)
		mine.set_hidden(true)
#	resets the timer
	_first_action_played = false
	_input_allowed = true
	_discovered_cells = 0
	emit_signal("new_match_created")


func newGame():
	for child in rowList.get_children():
		rowList.remove_child(child)
		child.queue_free()
	_mines = []
	_grid = []
	
	_grid = _grid_instance.create_new_grid(size, bombs_amount)
	_generate_UI_components()
	_init_mines()
	
	
	_first_action_played = false
	_input_allowed = true
	_discovered_cells = 0
	emit_signal("new_match_created")	


func quitGame():
	get_tree().quit()


func changeGridSize(item: int):
	if item == 0:
		size = 9
		bombs_amount = 10
	elif item == 1:
		size = 16
		bombs_amount = 40
	elif item == 2:
		size = 22
		bombs_amount = 99
	newGame();
