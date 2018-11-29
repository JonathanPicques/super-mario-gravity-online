extends Navigation2D

func _ready():
	$NavigationPolygonInstanceLine2D.points = get_simple_path($FlagStart.position, $FlagEnd.position)