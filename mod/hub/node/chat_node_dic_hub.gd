extends ChatNode


var variable_name:String=""
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=40
	input_port_array=["Dictionary"]
	output_port_array=["Dictionary"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is Dictionary:
		sent_data_to_out(input_port_data[0],0,id)
		return true
	else:
		return false
