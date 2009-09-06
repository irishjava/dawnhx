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

class GraphNode<T> implements haxe.rtti.Generic
{
	public var val:T;
	
	public var next:GraphNode<T>;
	public var prev:GraphNode<T>;
	
	public var arcList:GraphArc<T>;
	public var marked:Bool;
	
	public function new(val:T)
	{
		this.val = val;
		arcList = null;
		marked = false;
	}
	
	public function iterator():Iterator<T>
	{
		return new GraphNodeIterator<T>(arcList);
	}
	
	inline public function link(graph:Graph<T>):Void
	{
		next = graph.nodeList;
		if (graph.nodeList != null)
			graph.nodeList.prev = this;
		graph.nodeList = this;
	}
	
	inline public function unlink(graph:Graph<T>):Void
	{
		var a:GraphArc<T> = arcList;
		var hook:GraphArc<T> = a;
		while (a != null)
		{
			hook = a.next;
			
			a.node = null;
			a.next = null;
			a.prev = null;
			
			a = hook;
		}
		
		if (prev != null) prev.next = next;
		if (next != null) next.prev = prev;
		if (this == graph.nodeList) graph.nodeList = next;
	}
	
	inline public function isConnected(target:GraphNode<T>):Bool
	{
		return getArc(target) != null;
	}
	
	inline public function isMutuallyConnected(target:GraphNode<T>):Bool
	{
		return getArc(target) != null && target.getArc(this) != null;
	}
	
	inline public function getArc(target:GraphNode<T>):GraphArc<T>
	{
		#if debug
		if (target == this)
			throw "target node equals current node";
		#end
		
		var a:GraphArc<T> = arcList;
		while (a != null)
		{
			if (a.node == target) break;
			a = a.next;
		}
		
		return a;
	}
	
	inline public function addArc(target:GraphNode<T>, cost:Float):Void
	{
		#if debug
		if (getArc(target) != null)
			throw this.val + " is already connected to " + target.val;
		if (target == this)
			throw "target node equals current node";
		#end
		
		new GraphArc<T>(target, cost).link(this);
	}

	/**
	 * Remove an arc that is pointing to the given target node.
	 */
	inline public function removeArc(target:GraphNode<T>):Void
	{
		#if debug
		if (getArc(target) == null)
			throw "node is not connected to target node";
		if (target == this)
			throw "target node equals current node";
		#end
		
		getArc(target).unlink(this);
	}
	
	/**
	 * Remove all outgoing arcs from this node.
	 */
	inline public function removeSingleArcs():Void
	{
		var arc = arcList;
		while (arc != null)
		{
			removeArc(arc.node);
			arc = arc.next;
		}
	}
	
	/**
	 * Remove all outgoing and incoming arcs from this node.
	 */
	inline public function removeMutualArcs():Void
	{
		var arc = arcList;
		while (arc != null)
		{
			arc.node.removeArc(this);
			removeArc(arc.node);
			arc = arc.next;
		}
		
		arcList = null;
	}
}

class GraphNodeIterator<T> implements haxe.rtti.Generic
{
	var _arcList:GraphArc<T>;
	
	public function new(arcList:GraphArc<T>)
	{
		_arcList = arcList;
	}
	
	public function hasNext():Bool
	{
		return _arcList != null;
	}
	
	public function next():T
	{
		var val:T = _arcList.node.val;
		_arcList = _arcList.next;
		return val;
	}
}