package uk.co.ziazoo.injector.mapping;

import uk.co.ziazoo.injector.provider.IProvider;

class Map implements IMap
{
	public var clazz(default,default):Class<Dynamic>;
	public var provider(default,default):IProvider;
	
	public function new()
	{
	}
	
	public function toClass(clazz:Class<Dynamic>):IProvider
	{
		return null;
	}
	
	public function toString():String
	{
		return "[Mapping clazz:" + clazz + "]";
	}
}