extends ChatNode
##字典转字符串节点，输入为字典，存在一个variable name成员，输出类型为bool和一个字符串，当字典内存在variable键时，输出true和对应的值，否则输出false和一个空字符串	
var variable_name:String=""
func _init(root:NodeRoot) -> void:
	super._init(root)
	type=6
	input_port_array=["Dictionary"]
	variable_name_array=["variable_name"]
	variable_type_array=[ChatNode.variable_type.TYPE_STRING]
	variable_type_more=[]
	variable_name_view=["字典键"]
	output_port_array=["Bool","String"]
	init_input()

func process_input(id:String)->bool:
	#print(variable_name)
	if input_port_data[0] is Dictionary:
		if input_port_data[0].has(variable_name):
			sent_data_to_out(true,0,id)
			sent_data_to_out(input_port_data[0][variable_name],1,id)
			
		else:
			sent_data_to_out(false,0,id)
			sent_data_to_out("",1,id)
		return true
	else:
		return false
	pass


func load_from_data(data:Dictionary):
	super.load_from_data(data)
	if data.has("variable_name"):
		var new_mes=data["variable_name"]
		variable_name=new_mes
		#print(new_mes)
func export_data(data:Dictionary):
	super.export_data(data)
	#print("当前字典键",variable_name)
	data["variable_name"]=variable_name
