package uk.co.ziazoo.injector.inspect;

import de.polygonal.ds.TreeNode;

import uk.co.ziazoo.injector.mapping.IMapper;
import uk.co.ziazoo.injector.mapping.IMap;

class Inspector implements IInspector
{
	public var mapper(default,default):IMapper;
	
	public function new()
	{
	}
	
	public function inspect(mapping:IMap, parent:TreeNode<IMap> = null):TreeNode<IMap>
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
}