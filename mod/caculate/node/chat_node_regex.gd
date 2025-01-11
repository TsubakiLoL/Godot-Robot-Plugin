extends ChatNode
##正则匹配节点
var regex_string:String="":
	set(val):
		regex=RegEx.create_from_string(val)
		regex_string=val
var regex=RegEx.new()
func _init(root:NodeRoot) -> void:
	super._init(root)
	variable_name_array=["regex_string"]
	variable_type_array=[ChatNode.variable_type.TYPE_STRING]
	variable_name_view=["正则表达式"]
	input_port_array=["String"]
	output_port_array=["Bool","Dictionary"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is String and regex.is_valid():
		var res=regex.search(input_port_data[0])
		if res==null:
			sent_data_to_out(false,0,id)
			sent_data_to_out({},1,id)
		else:
			var exe_res:Dictionary={}
			for i in res.names.keys():
				exe_res[i]=res.strings[res.names[i]]
			if res.names.size()!=0:
				sent_data_to_out(true,0,id)
				sent_data_to_out(exe_res,1,id)
			else:
				sent_data_to_out(false,0,id)
				sent_data_to_out({},1,id)
		return true
	else:
		return false

func load_from_data(data:Dictionary):
	super.load_from_data(data)
	if data.has("regex_string"):
		var new_mes=data["regex_string"]
		regex_string=new_mes
func export_data(data:Dictionary):
	super.export_data(data)
	data["regex_string"]=regex_string
