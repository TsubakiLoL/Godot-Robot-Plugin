extends ChatNode
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=13
	input_port_array=["String","String"]
	output_port_array=["String"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is String and input_port_data[1] is String :
		sent_data_to_out(input_port_data[0]+input_port_data[1],0,id)
		return true
	else:
		return false
