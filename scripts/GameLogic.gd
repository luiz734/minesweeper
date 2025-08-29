extends MarginContainer

signal player_won
signal player_lost
signal game_started
signal game_finished
signal new_match_created

@export var grid_size: int = 6
@export var bombs_amount: int = 5

var Mine = preload("res://scenes/mine.tscn")
var MineBomb = preload("res://scenes/MineBomb.tscn")
var Grid = load("res://scripts/GameGenerator.gd")

@onready var rowList = $rowList
@onready var timer = $"../menuArea/background/margin/buttons/timeMargin/timeLabel"
@onready var UI_controler = get_tree().get_root()


# TODO: change from "mines" to "cells"
var _grid_instance = Grid.new()
var _grid = []
var _mines = []
var _discovered_cells = 0
var _first_action_played = false
var _input_allowed = true

func _ready():
    assert(connect("game_started", Callable(timer, "start")) == OK)
    assert(connect("game_finished", Callable(timer, "stop")) == OK)
    assert(connect("new_match_created", Callable(timer, "clear")) == OK)
    newGame()


func _generate_UI_components():
    for row in range(grid_size):
        var new_row = HBoxContainer.new()
        new_row.size_flags_horizontal = SIZE_EXPAND_FILL
        new_row.size_flags_vertical = SIZE_EXPAND_FILL
        new_row.set_name("row-" + str(row))
        new_row.set("theme_override_constants/separation", -5)
        rowList.add_child(new_row)


        for i in range(grid_size):
            var new_mine
            if _grid[row * grid_size + i] == -1:
                new_mine = MineBomb.instantiate()
            else:
                new_mine = Mine.instantiate()

            new_mine.cell_clicked.connect(handle_player_action)
            _mines.push_back(new_mine)
            new_row.add_child(new_mine)
            new_mine.set_name("mine-" + str(i))
            new_mine.set_hidden(true)


func _init_mines():
    for i in range(grid_size * grid_size):
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
    if row < 0 or row >= grid_size or col < 0 or col >= grid_size:
        return false
    return true


func reveal_value(index):
    if not _mines[index].get_hidden():
        return

    _mines[index].set_hidden(false)
    _discovered_cells += 1
    if _discovered_cells == (grid_size * grid_size) - bombs_amount:
        print("GANHOU")
        _input_allowed = false
        emit_signal("game_finished")
        emit_signal("player_won")


    var row: int = index / grid_size
    var col: int = index % grid_size

    if _mines[index].value == 0:
        for i in range(-1, 2):
            for j in range(-1, 2):
                var ajacent_mine_idx = (row + i) * grid_size + (col + j)
                if _is_index_valid(row + i, col + j):
                    reveal_value(ajacent_mine_idx)


func resetGame():
    for mine in _mines:
        mine.reset_to_default()
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

    _grid = _grid_instance.create_new_grid(grid_size, bombs_amount)
    _generate_UI_components()
    _init_mines()


    _first_action_played = false
    _input_allowed = true
    _discovered_cells = 0
    new_match_created.emit()


func quitGame():
    get_tree().quit()

func changeGridSize(item: int):
    if item == 0:
        grid_size = 6
        bombs_amount = 5
    elif item == 1:
        grid_size = 9
        bombs_amount = 10
    elif item == 2:
        grid_size = 12
        bombs_amount = 20
    Globals.grid_size_changed.emit(grid_size)

    newGame();
