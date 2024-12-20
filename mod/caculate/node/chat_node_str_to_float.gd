extends ChatNode

func _init(root:NodeRoot) -> void:
	super._init(root)
	type=23
	input_port_array=["String"]
	output_port_array=["Float"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is String and input_port_data[0].is_valid_float():
		sent_data_to_out(input_port_data[0].to_float(),0,id)
	else:
		sent_data_to_out(0,0,id)
	return true
