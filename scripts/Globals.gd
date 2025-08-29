extends Node

var cell_theme = preload("res://themes/cell_theme.tres")

signal grid_size_changed(value: int)

func _ready() -> void:
    grid_size_changed.connect(func(grid_size: int):
        if grid_size == 6:
            cell_theme.set("Label/font_sizes/font_size", 80)
        elif grid_size == 9:
            cell_theme.set("Label/font_sizes/font_size", 48)
        else:
            cell_theme.set("Label/font_sizes/font_size", 32)
    )
