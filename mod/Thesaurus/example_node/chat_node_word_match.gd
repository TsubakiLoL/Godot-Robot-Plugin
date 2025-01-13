extends ChatNode


#节点初始化
func _init(root:NodeRoot) -> void:
	#父类初始化
	super._init(root)
	#输入节点类型数组
	input_port_array=["String"]
	#输出节点类型数组
	output_port_array=["Bool","String"]
	init_input()


#当全部输入就绪时调用
#处理输入，输入的为状态机的标识ID，大部分情况为用户ID
func process_input(id:String):
	#第0个端口的输入数据，获取方式以此类推
	if input_port_data[0] is String and input_port_data[0]:
		
		#将true发送到第0个输出端口，并传入ID
		sent_data_to_out(true,0,id)
		#将"hello starbot"发送到第1个输出端口
		sent_data_to_out("hello starbot!",1,id)
		
		var res=get_autoload().match_all(input_port_data[0])
		
		if not res is Array[String]:
			sent_data_to_out(false,0,id)
			sent_data_to_out("null",1,id)
			return true
		if res.size()==0:
			sent_data_to_out(false,0,id)
			sent_data_to_out("null",1,id)
			return true
		var size:int=res.size()
		var rand=randi_range(-1,size-1)
		sent_data_to_out(true,0,id)
		sent_data_to_out(res[rand],1,id)
		return true
		
	
	
	return false


#获取单例
func get_autoload():
	return ModLoader.get_autoload("thesaurus/autoload")


