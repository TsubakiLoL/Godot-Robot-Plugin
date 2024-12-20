extends ChatNode
##非门，输入一个bool，输出为输入的非，为bool类型
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=12
	input_port_array=["Bool"]
	output_port_array=["Bool"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is bool :
		sent_data_to_out(not input_port_data[0],0,id)
		return true
	else:
		return false
