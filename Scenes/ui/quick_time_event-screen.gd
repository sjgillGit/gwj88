extends Control

@onready var quick_time_event_panel = %QuickTimeEventPanel
@onready var event = %Event
@onready var instruction = %Instruction

var _quick_time_events_queue: Array = []
var action: GUIDEAction = preload("res://Scripts/guide/action.tres")

class QTE extends Node:
	signal completion(action_taken: bool)
	signal exiting_tree()

	var event_text: String
	var priority: int
	var timer: Timer
	var completion_callable: Callable



	func _init(
		_event_text: String,
		_priority: int,
		_timer: Timer,
		_completion_callable: Callable,
	):
		event_text = _event_text
		priority = _priority
		timer = _timer
		completion_callable = _completion_callable


	func _ready():
		if timer:
			timer.timeout.connect(func():
				completion.emit(false)
				completion_callable.call(false)
			)

	func _exit_tree():
		exiting_tree.emit()

	func complete_action():
		completion.emit(true)
		completion_callable.call(true)


	func cancel_action():
		completion.emit(false)
		completion_callable.call(false)


func _sample_quicktime_callable(action_taken: bool):
	print("Quick Time Event completed, action_taken: %s" % action_taken)


##
## event text will be displayed in the pop-up
## priority is used to determine which quick time event is shown
##   when multiple events are present
## expiration time of 0.0 will never time out
## completion callable can be used to handle quick time event
##   being fulfilled.
func add_quick_time_event(
	parent: Node,
	event_text: String,
	priority: int = 1,
	expiration_time: float = 0.0,
	completion_callable: Callable = _sample_quicktime_callable,
) -> QTE:
	var timer: Timer
	if expiration_time > 0.0:
		timer = Timer.new()
		timer.wait_time = expiration_time
		timer.autostart = true
		parent.add_child(timer)

	var qte = QTE.new(event_text, priority, timer, completion_callable)
	qte.exiting_tree.connect(func():
		_quick_time_events_queue.erase(qte)
		qte.queue_free()
	)
	qte.completion.connect(func(_unused):
		_quick_time_events_queue.erase(qte)
		qte.queue_free()
	)
	parent.add_child(qte)
	if _quick_time_events_queue.is_empty():
		_quick_time_events_queue.append(qte)
	else:
		var insert_index = _quick_time_events_queue.find_custom(func(e: QTE):
			return e.priority < qte.priority
		)
		if insert_index == -1:
			_quick_time_events_queue.append(qte)
		else:
			_quick_time_events_queue.insert(insert_index, qte)
	return qte

func remove_quick_time_event(qte) -> void:
	_quick_time_events_queue.erase(qte)

func _process(_delta):
	if not _quick_time_events_queue.is_empty():
		var qte: QTE = _quick_time_events_queue.get(0)
		event.text = qte.event_text
		quick_time_event_panel.show()
	else:
		quick_time_event_panel.hide()


func _ready():
	action.triggered.connect(func():
		var qte: QTE = _quick_time_events_queue.get(0)
		if qte:
			qte.complete_action()
	)


func _sample_usage():
	var qte: QuickTimeEventScreen.QTE = QuickTimeEventScreen.add_quick_time_event(
		self,
		"Quick Time Test",
		3,
		5.0,
		func(action_taken):
			print("Quick Time Test Callable: %s" % action_taken)
	)
	qte.completion.connect(func(action_taken: bool):
		print("Quick Time Test signal: %s" % action_taken)
	)
	QuickTimeEventScreen.add_quick_time_event(
		self,
		"Longer Quick Time Test",
		2,
		10.0,
	)
	QuickTimeEventScreen.add_quick_time_event(
		self,
		"Infinite Time Quick Time",
		1,
		0.0,
	)
