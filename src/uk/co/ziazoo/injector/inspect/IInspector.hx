package uk.co.ziazoo.injector.inspect;

import de.polygonal.ds.TreeNode;

import uk.co.ziazoo.injector.mapping.IMapper;
import uk.co.ziazoo.injector.mapping.IMap;

interface IInspector
{
	var mapper(default,default):IMapper;
	
	function inspect(mapping:IMap, node:TreeNode<IMap> = null):TreeNode<IMap>;
}