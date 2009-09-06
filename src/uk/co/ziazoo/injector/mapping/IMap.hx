package uk.co.ziazoo.injector.mapping;

import uk.co.ziazoo.injector.provider.IProvider;

interface IMap
{
	var clazz(default,default):Class<Dynamic>;
	var provider(default,default):IProvider;
	
	function toClass(clazz:Class<Dynamic>):IProvider;
}