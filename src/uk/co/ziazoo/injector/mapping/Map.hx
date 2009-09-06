package uk.co.ziazoo.injector.mapping;

import uk.co.ziazoo.injector.provider.Provider;

class Map implements IMap
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