extends Label

@export var state_machine : CharacterStateMachine

func _process(_delta):
	text = "State: " + state_machine.current_state.name
