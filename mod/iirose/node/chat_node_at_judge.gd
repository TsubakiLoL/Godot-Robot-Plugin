extends ChatNode
##蔷薇艾特监测
var regex=RegEx.create_from_string("^[ ]+\\[\\*(?<name>[^\\]^\\*]+)\\*\\][ ]+$")

var is_contain:bool=false:
	set(value):
		is_contain=value
		if value:
			regex=RegEx.create_from_string(" \\[\\*(?<name>[^\\]^\\*]+)\\*\\] ")
		else:
			RegEx.create_from_string("^[ ]+\\[\\*(?<name>[^\\]^\\*]+)\\*\\][ ]+$")

func _init(root:NodeRoot) -> void:
	super._init(root)
	input_port_array=["String"]
	output_port_array=["Bool","String"]
	variable_name_array=["is_contain"]
	variable_type_array=[ChatNode.variable_type.TYPE_BOOL]
	variable_type_more=[]
	variable_name_view=["匹配包含"]
	init_input()

func process_input(id:String)->bool:
	if input_port_data[0] is String and regex.is_valid():
		var res=regex.search(input_port_data[0])
		if res==null:
			#如果未匹配到
			print("结果为null")
			sent_data_to_out(false,0,id)
			sent_data_to_out("",1,id)
		else:
			#如果匹配到名字
			print("结果不为null")
			if res.names.keys().has("name"):
				sent_data_to_out(true,0,id)
				sent_data_to_out(res.strings[res.names["name"]],1,id)
			else:
				print("未匹配到名字",res.names.keys())
				sent_data_to_out(false,0,id)
				sent_data_to_out("",1,id)
		return true
	else:
		return false

func load_from_data(data:Dictionary):
	super.load_from_data(data)
	if data.has("is_contain"):
		var new_mes=data["is_contain"]
		is_contain=new_mes
func export_data(data:Dictionary):
	super.export_data(data)
	data["is_contain"]=is_contain
	
	

