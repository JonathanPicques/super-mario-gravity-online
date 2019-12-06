extends Label

var ms = 0
var s = 0
var m = 0

func _ready():
	print("TODO: add timer into the game multiplayer and sync it")

func _process(delta):
	if ms > 9:
		s += 1
		ms = 0
	
	if s > 59:
		m += 1
		s = 0
	
	text = "%s:%s:%s" % [
		str(m) if m > 9 else "0" + str(m),
		str(s) if s > 9 else "0" + str(s),
		str(ms)
	]


func _on_MSTimer_timeout():
	ms += 1
