package uk.co.ziazoo.injector.mapping;

interface IMapper
{
	function map(clazz:Class<Dynamic>):IMap;
	function getMapping(clazz:Class<Dynamic>):IMap;
}