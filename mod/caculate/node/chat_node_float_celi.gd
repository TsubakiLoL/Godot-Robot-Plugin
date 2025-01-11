extends ChatNode
func _init(root:NodeRoot) -> void:
	super._init(root)
	input_port_array=["Float"]
	output_port_array=["Float"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is float:
		if input_port_data[0]>0:
			sent_data_to_out(float(int(input_port_data[0])+1),0,id)
		elif input_port_data[0]==0:
			sent_data_to_out(0,0,id)
		else:
			sent_data_to_out(float(int(input_port_data[0])),0,id)
		return true
	else:
		return false
	
	
