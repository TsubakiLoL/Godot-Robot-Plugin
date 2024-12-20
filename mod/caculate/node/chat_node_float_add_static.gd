extends ChatNode
var mes:String=""
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=24
	variable_name_array=["mes"]
	variable_type_array=[ChatNode.variable_type.TYPE_STRING]
	variable_type_more=[]
	variable_name_view=["输出(请填写有效数字，否则会输出原数字)"]
	input_port_array=["Float"]
	output_port_array=["Float"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is float and mes.is_valid_float():
		sent_data_to_out(input_port_data[0]+mes.to_float(),0,id)
		return true
	elif input_port_data[0] is float:
		sent_data_to_out(input_port_data[0],0,id)
		return true
	else:
		return false
	
	
	
	
	
func load_from_data(data:Dictionary):
	super.load_from_data(data)
	if data.has("mes"):
		var new_mes=data["mes"]
		mes=new_mes
func export_data(data:Dictionary):
	super.export_data(data)
	data["mes"]=mes
