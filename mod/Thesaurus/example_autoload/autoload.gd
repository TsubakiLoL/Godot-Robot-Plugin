extends Node
#当前持有的词库数据（一对一）
var word_data:Dictionary={}
#当前持有的持久化数据
var forever_data:Dictionary={}

#获取自己加载的路径
var load_path:String:
	get():
		return ModLoader.get_mod_path("thesaurus")

func _ready():
	
	
	
	pass
func prcess_message(str:String):
	
	
	pass
class word:
	var regex:RegEx
	var from_regex:String
	var to_regex:String
	#构造器
	func _init(from:String,to:String):
		#从开始进行匹配
		regex=RegEx.create_from_string(from)
		from_regex=from
		to_regex=to
	#输入文本是否匹配,并且获得处理好的语句
	func match(text:String):
		
		if regex.is_valid():
			var res=regex.search(text)
			if res==null:
				return [false,null]
			else:
				var exe_res:Dictionary={}
				for i in res.names.keys():
					exe_res[i]=res.strings[res.names[i]]
				var to_str=to_regex
				var match_place=to_str.format(exe_res)
				return [true,match_place]
		else:
			return [false,null]
	
func add_word(from:String,to:String)->bool:
	if word_data.has(from):
		return false
	word_data[from]=word.new(from,to)
	return true
func delete_word(from:String):
	word_data.erase(from)


#获得当前的词库列表
func get_word_view_str()->String:
	var str="当前词库:\n"
	if word_data.size()==0:
		return "当前词库是空的 Σヽ(ﾟД ﾟ; )ﾉ"
	for i in word_data.values():
		if i is word:
			str+="\t"+i.from_regex+"\t"+i.to_regex+"\n"
	return str


func match_all(text:String):
	var res:Array[String]=[]
	for i in word_data.values():
		if  i is word:
			var result=i.match(text)
			if result[0]:
				res.append(result[1])
	return res




