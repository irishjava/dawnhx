import de.polygonal.ds.TreeNode;

class DawnHX
{
	public var mapper(default,default):IMapper;
	
	public function new( config:IConfig )
	{
		mapper = new Mapper();
		config.configure(mapper);
	}
	
	public function getObject<T>(clazz:Class<Dynamic>):T
	{
		var tree:TreeNode<Mapping> = inspect(mapper.getMapping(clazz));
		var dump:String = "\n";
		
		tree.preOrder( 
			function(node:TreeNode<Mapping>):Bool
			{
				var d:Int = node.depth();
				for (i in 0...d)
				{
					if (i == d - 1)
						dump += "+---";
					else
						dump += "|    ";
				}
				dump += node + "\n";
				return true;
			});
			
		trace(dump);
		return null;
	}
	
	private function inspect(mapping:Mapping, parent:TreeNode<Mapping> = null):TreeNode<Mapping>
	{
		var node:TreeNode<Mapping> = new TreeNode<Mapping>( mapping, parent );
		
		var rtti:String = untyped mapping.clazz.__rtti;
		var root = Xml.parse(rtti).firstElement();
		var infos = new haxe.rtti.XmlParser().processElement(root);
		
		switch(infos)
		{
			default:
			case TClassdecl(classDef):
				for(field in classDef.fields) 
					if(field.doc != null) 
					if(hasInject(field.doc))
				{
					switch(field.type)
					{
						default:
						case CClass(name, params):
							var clazz:Class<Dynamic> = Type.resolveClass(name);
							inspect(mapper.getMapping(clazz), node);
					}
				}
		}
		
		return node;
	}
	
	private function hasInject(doc:String):Bool
	{
		return doc.indexOf("@Inject") > -1;
	}
		
	public static function main():Void
	{
		var m:DawnHX = new DawnHX(new TestConfig());
		m.getObject(Thing);
	}
}

class Mapper implements IMapper
{
	private var _mappings:Array<Mapping>;
	
	public function new()
	{
		_mappings = new Array();
	}
	
	public function map(clazz:Class<Dynamic>):Mapping
	{
		var mapping:Mapping = new Mapping();
		mapping.clazz = clazz;
		
		_mappings.push(mapping);
		
		return mapping;
	}
	
	public function getMapping(clazz:Class<Dynamic>):Mapping
	{
		for(mapping in _mappings)
		{
			if(mapping.clazz == clazz)
			{
				return mapping;
			}
		}
		return null;
	}
}

class Mapping
{
	public var clazz(default,default):Class<Dynamic>;
	public var provider(default,default):Provider;
	
	public function new()
	{
	}
	
	public function toString():String
	{
		return "[Mapping clazz:" + clazz + "]";
	}
}

class Provider
{
	public function new()
	{
	}
}

interface IConfig
{
	function configure(mapper:IMapper):Void;
}

interface IMapper
{
	function map(clazz:Class<Dynamic>):Mapping;
	function getMapping(clazz:Class<Dynamic>):Mapping;
}

class Thing implements haxe.rtti.Infos
{
	/**
	*	@Inject
	*/
	public var dude:Dude;

	public function new()
	{
	}
}

class Bike implements haxe.rtti.Infos
{
	public function new()
	{
	}
}

class Dude implements haxe.rtti.Infos
{
	/**
	*	@Inject
	*/
	public var bike(default,default):Bike;
	
	public function new()
	{
	}
}

class TestConfig implements IConfig
{
	public function new()
	{
	}
	
	public function configure(mapper:IMapper):Void
	{
		mapper.map(Thing);
		mapper.map(Dude);
		mapper.map(Bike);
	}
}