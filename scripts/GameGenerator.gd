class_name GameGenerator

var _grid = []
var _size = 0
var _bombs_amount = 0

func _init():
	randomize()

func _create_empty_grid():
	_grid = []
	for i in range(_size * _size):
		_grid.push_back(0)
	
func _fill_grid_with_bombs():
	for i in range(_bombs_amount):
		var mine_index = randi() % _grid.size()
		while _grid[mine_index] == -1:
			mine_index = randi() % _grid.size()
		
		_grid[mine_index] = -1 

func _is_index_valid(row: int, col: int):
	if row < 0 or row >= _size or col < 0 or col >= _size:
		return false
	return true

func _fill_grid_with_values():
	for mine_idx in range(_size * _size):
		var row: int = mine_idx / _size
		var col: int = mine_idx % _size
		
		if _grid[mine_idx] != -1:
			var total_mines_near = 0
			for i in range(-1, 2):
				for j in range(-1, 2):
					var index = (row + i) * _size + (col + j)
					if _is_index_valid(row + i, col + j):
						if _grid[index] == -1:
							total_mines_near += 1
			_grid[mine_idx] = total_mines_near
	
func get_grid():
	return _grid
	
func create_new_grid(size: int, bombs_amount: int) -> Array:
	_size = size
	_bombs_amount = bombs_amount

	
	_create_empty_grid()
	_fill_grid_with_bombs()
	_fill_grid_with_values()
	
	return _grid

