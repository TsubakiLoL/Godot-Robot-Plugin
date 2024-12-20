extends ChatNode

var variable_name:String=""
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=41
	input_port_array=["Float"]
	output_port_array=["Float"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is float:
		sent_data_to_out(input_port_data[0],0,id)
		return true
	else:
		return false
