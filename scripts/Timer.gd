extends Label

onready var timer = $timer

var total_seconds = 0
var total_minutes = 0


func _increment_one_second():
	total_seconds += 1
	if total_seconds == 60:
		total_seconds = 0
		total_minutes += 1
	
	update_label()


func start():
	timer.start()


func stop():
	timer.stop()


func clear():
	if timer:
		timer.stop()
	total_seconds = 0
	total_minutes = 0
	update_label()

func update_label():
	text = "%02d" % total_minutes + ":" + "%02d" % total_seconds
