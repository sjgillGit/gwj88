extends Label

@onready var _fmt_string := text

func format(values: Variant):
	text = _fmt_string.format(values)
