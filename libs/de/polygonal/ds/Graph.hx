/*
 * HX3DS - DATA STRUCTURES FOR GAME PROGRAMMERS
 * Copyright (c) 2009 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package de.polygonal.ds;

import de.polygonal.ds.ArrayedStack;
import flash.Vector;

class Graph<T> implements haxe.rtti.Generic
{
	public var nodeList:GraphNode<T>;
	
	private var _curSize:Int;
	private var _maxSize:Int;
	
	private var _stack:Vector<GraphNode<T>>;
	private var _que:Vector<GraphNode<T>>;
	
	#if debug
	private var _nodeSet:Set<GraphNode<T>>;
	#end
	
	public function new(size:Int)
	{
		#if debug
		var isPow2:Bool = size > 0 && (size & (size - 1)) == 0;
		if (isPow2 == false)
			throw "size is not a power of 2";
		#end
		
		_curSize = 0;
		_maxSize = size;
		nodeList = null;
		_stack = new Vector<GraphNode<T>>(size, true);
		_que = new Vector<GraphNode<T>>(size, true);
		
		#if debug
		_nodeSet = new Set<GraphNode<T>>();
		#end
	}
	
	inline public function maxSize():Int
	{
		return _maxSize;
	}
	
	inline public function getNodeList():GraphNode<T>
	{
		return nodeList;
	}
	
	inline public function addNode(val):GraphNode<T>
	{
		var node:GraphNode<T> = new GraphNode<T>(val);
		
		#if debug
		if (_curSize == _maxSize) throw "graph is full";
		_nodeSet.set(node);
		#end
		
		node.link(this);
		_curSize++;
		return node;
	}
	
	/**
	 * Creates a uni-directional arc between the source and target node.
	 */
	inline public function addSingleArc(source:T, target:T, cost:Float):Void
	{
		#if debug
		if (source == target) throw "source equals target";
		#end
		
		var walker:GraphNode<T> = nodeList;
		while (walker != null)
		{
			if (walker.val == source)
			{
				var sourceNode:GraphNode<T> = walker;
				
				walker = nodeList;
				while (walker != null)
				{
					sourceNode.addArc(walker, cost);
					break;
					walker = walker.next;
				}
			}
			walker = walker.next;
		}
	}
	
	/**
	 * Creates a bi-directional arc between the source and target node.
	 */
	inline public function addMutualArc(source:T, target:T, cost:Float):Void
	{
		#if debug
		if (source == target) throw "source equals target";
		#end
		
		var walker:GraphNode<T> = nodeList;
		while (walker != null)
		{
			if (walker.val == source)
			{
				var sourceNode:GraphNode<T> = walker;
				
				walker = nodeList;
				while (walker != null)
				{
					if (walker.val == target)
					{
						sourceNode.addArc(walker, cost);
						walker.addArc(sourceNode, cost);
						break;
					}
					
					walker = walker.next;
				}
				break;
			}
			walker = walker.next;
		}
	}
	
	inline public function removeNode(node:GraphNode<T>):Void
	{
		#if debug
		if (_curSize == 0) throw "graph is empty";
		if (!_nodeSet.has(node)) throw "unknown node";
		#end
		
		node.unlink(this);
		_curSize--;
		
		var n:GraphNode<T> = nodeList;
		while (n != null)
		{
			if (n.getArc(node) != null)
				n.removeArc(node);
			n = n.next;
		}
	}
	
	inline public function clearMarks():Void
	{
		var node:GraphNode<T> = nodeList;
		while (node != null)
		{
			node.marked = false;
			node = node.next;
		}
	}
	
	public function DFS(node:GraphNode<T>, visit:GraphNode<T>->Bool, ?visitable:GraphNode<T>->Bool = null):Void
	{
		#if debug
		if (node == null) throw "invalid node";
		#end
		
		var c:Int = 1;
		_stack[0] = node;
		
		if (visitable != null)
		{
			while (c > 0)
			{
				var n:GraphNode<T> = _stack[--c];
				if (n.marked) continue;
				n.marked = true;
				
				if (!visit(n)) break;
				
				var a:GraphArc<T> = n.arcList;
				while (a != null)
				{
					if (visitable(a.node))
						_stack[c++] = a.node;
					a = a.next;
				}
			}
		}
		else
		{
			while (c > 0)
			{
				var n:GraphNode<T> = _stack[--c];
				if (n.marked) continue;
				n.marked = true;
				
				if (!visit(n)) break;
				
				var a:GraphArc<T> = n.arcList;
				while (a != null)
				{
					_stack[c++] = a.node;
					a = a.next;
				}
			}
		}
	}
	
	public function BFS(node:GraphNode<T>, visit:GraphNode<T>->Bool, ?visitable:GraphNode<T>->Bool):Void
	{
		#if debug
		if (node == null) throw "invalid node";
		#end
		
		var divisor:Int = _maxSize - 1;
		var front:Int = 0;
		
		var c:Int = 1;
		_que[0] = node;
		node.marked = true;
		
		if (visitable != null) 
		{
			while (c > 0)
			{
				var n:GraphNode<T> = _que[front];
				if (!visit(n)) return;
				var a:GraphArc<T> = n.arcList;
				while (a != null)
				{
					var m:GraphNode<T> = a.node;
					if (m.marked)
					{
						a = a.next;
						continue;
					}
					m.marked = true;
					if (visitable(m))
						_que[(c++ + front) & divisor] = m;
					a = a.next;
				}
				if (++front == _maxSize) front = 0;
				c--;
			}
		}
		else
		{
			while (c > 0)
			{
				var n:GraphNode<T> = _que[front];
				if (!visit(n)) return;
				var a:GraphArc<T> = n.arcList;
				while (a != null)
				{
					var m:GraphNode<T> = a.node;
					if (m.marked)
					{
						a = a.next;
						continue;
					}
					m.marked = true;
					_que[(c++ + front) & divisor] = m;
					a = a.next;
				}
				if (++front == _maxSize) front = 0;
				c--;
			}
		}
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:T):Bool
	{
		var node:GraphNode<T> = nodeList;
		while (node != null)
		{
			if (node.val == val) return true;
			node = node.next;
		}
		return false;
	}
	
	public function clear():Void
	{
		var node:GraphNode<T> = nodeList;
		var hook:GraphNode<T>;
		while (node != null)
		{
			hook = node.next;
			node.unlink(this);
			node = hook;
		}
		
		nodeList = null;
		_curSize = 0;
		
		for (i in 0..._maxSize)
		{
			_stack[i] = null;
			_que[i] = null;
		}
	}

	public function iterator():Iterator<T>
	{
		return new GraphIterator<T>(nodeList);
	}
	
	public function size():Int
	{
		return _curSize;
	}
	
	public function isEmpty():Bool
	{
		return _curSize == 0;
	}
	
	public function toArray():Array<T>
	{
		var a:Array<T> = new Array<T>();
		var i:Int = 0;
		var node:GraphNode<T> = nodeList;
		while (node != null)
		{
			a[i++] = node.val;
			node = node.next;
		}
		return a;
	}
	
	public function toVector():Vector<T>
	{
		var v:Vector<T> = new Vector<T>(_curSize, true);
		var i:Int = 0;
		var node:GraphNode<T> = nodeList;
		while (node != null)
		{
			v[i++] = node.val;
			node = node.next;
		}
		return v;
	}
	
	public function shuffle():Void
	{
		throw "unsupported operation";
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		if (copier == null)
			copier = function(val:T):T { return val; };
		
		var copy:Graph<T> = new Graph<T>(_maxSize);
		
		var tmp:Vector<GraphNode<T>> = new Vector<GraphNode<T>>();
		var i:Int;
		
		var n:GraphNode<T>;
		var m:GraphNode<T>;
		
		i = 0;
		n = nodeList;
		while (n != null)
		{
			m = copy.addNode(copier(n.val));
			tmp[i++] = m;
			n = n.next;
		}
		
		i = 0;
		n = nodeList;
		while (n != null)
		{
			m = tmp[i++];
			var a:GraphArc<T> = n.arcList;
			while (a != null)
			{
				m.addArc(a.node, a.cost);
				a = a.next;
			}
			n = n.next;
		}
		
		return cast copy;
	}
}

import de.polygonal.ds.Graph;
import de.polygonal.ds.GraphNode;

class GraphIterator<T> implements haxe.rtti.Generic
{
	private var _node:GraphNode<T>;

	public function new(node:GraphNode<T>)
	{
		_node = node;
	}

	public function hasNext():Bool
	{
		return _node != null;
	}

	public function next():T
	{
		var val:T = _node.val;
		_node = _node.next;
		return val;
	}
}