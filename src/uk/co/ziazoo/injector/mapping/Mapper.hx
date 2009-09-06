package uk.co.ziazoo.injector.mapping;

class Mapper implements IMapper
{
	private var _mappings:Array<IMap>;
	
	public function new()
	{
		_mappings = new Array();
	}
	
	public function map(clazz:Class<Dynamic>):IMap
	{
		var mapping:IMap = new Map();
		mapping.clazz = clazz;
		
		_mappings.push(mapping);
		
		return mapping;
	}
	
	public function getMapping(clazz:Class<Dynamic>):IMap
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