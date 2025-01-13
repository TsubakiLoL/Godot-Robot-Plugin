extends ChatNode


#节点初始化
func _init(root:NodeRoot) -> void:
	#父类初始化
	super._init(root)
	#输入节点类型数组
	input_port_array=["Bool","String","String"]
	#输出节点类型数组
	output_port_array=["Bool"]
	init_input()


#当全部输入就绪时调用
#处理输入，输入的为状态机的标识ID，大部分情况为用户ID
func process_input(id:String):
	#第0个端口的输入数据，获取方式以此类推
	if input_port_data[0] is bool and input_port_data[1] is String and input_port_data[2] is String:
		if input_port_data[0]:
			var res=get_autoload().add_word(input_port_data[1],input_port_data[2])
			sent_data_to_out(res,0,id)
			return true
		else:
			return false
		
	
	
	return false


#获取单例
func get_autoload():
	return ModLoader.get_autoload("thesaurus/autoload")


