extends ChatNode
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=25
	input_port_array=["Float","Float"]
	output_port_array=["Float"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is float and input_port_data[1] is float:
		sent_data_to_out(input_port_data[0]+input_port_data[1],0,id)
		return true
	else:
		return false
	
	
	
