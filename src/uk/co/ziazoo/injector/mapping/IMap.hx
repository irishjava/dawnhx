package uk.co.ziazoo.injector.mapping;

import uk.co.ziazoo.injector.provider.Provider;

interface IMap
{
	var clazz(default,default):Class<Dynamic>;
	var provider(default,default):Provider;
}