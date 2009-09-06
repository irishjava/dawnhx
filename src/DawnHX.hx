import de.polygonal.ds.TreeNode;

import uk.co.ziazoo.injector.inspect.IInspector;

import uk.co.ziazoo.injector.mapping.IMap;
import uk.co.ziazoo.injector.mapping.IMapper;
import uk.co.ziazoo.injector.mapping.Mapper;

class DawnHX
{
	public var mapper(default,default):IMapper;
	public var inspector(default,default):IInspector;
	
	public function new(config:IConfig)
	{
		mapper = new Mapper();
		config.configure(mapper);
	}
	
	public function getObject<T>(clazz:Class<Dynamic>):T
	{
		var tree:TreeNode<IMap> = inspect(mapper.getMapping(clazz));
		var dump:String = "\n";
		
		tree.preOrder( 
			function(node:TreeNode<IMap>):Bool
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
	
	private function inspect(mapping:IMap, parent:TreeNode<IMap> = null):TreeNode<IMap>
	{
		var node:TreeNode<IMap> = new TreeNode<IMap>( mapping, parent );
		
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
					inspectCType(field.type, node);
				}
		}
		
		return node;
	}
	
	private function inspectCType(type:haxe.rtti.CType, node:TreeNode<IMap>):Void
	{
		switch(type)
		{
			default:
			case CClass(name, params):
				var clazz:Class<Dynamic> = Type.resolveClass(name);
				inspect(mapper.getMapping(clazz), node);
			case CFunction(args, ret):
				for(arg in args)
				{
					inspectCType(arg.t, node);
				}
		}
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

interface IConfig
{
	function configure(mapper:IMapper):Void;
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
	public function new(bike:Bike, wallet:Wallet)
	{
	}
}

class Wallet implements haxe.rtti.Infos
{
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
		mapper.map(Wallet);
	}
}