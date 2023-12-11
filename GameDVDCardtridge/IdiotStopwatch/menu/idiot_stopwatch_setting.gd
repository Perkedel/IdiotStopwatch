extends Control

class_name IdiotStopWatchSetting

var activo:bool = false
var _bufferCounter:int = 0

@onready var counterSpin:SpinBox = $VBoxContainer/SetBar/CounterSpinBox

signal changeCounter(to)
signal offerReset(the)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setBufferCounter(to:int):
	_bufferCounter = to
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			counterSpin.value = _bufferCounter
			activo = true
			pass
		else:
			activo = false
			pass

func _on_spin_box_value_changed(value):
	if activo:
		emit_signal("changeCounter",value)
		pass
	pass # Replace with function body.


func _on_clear_counter_pressed():
	emit_signal("offerReset",'counter')
	pass # Replace with function body.


func _on_clear_log_pressed():
	emit_signal('offerReset','logs')
	pass # Replace with function body.
