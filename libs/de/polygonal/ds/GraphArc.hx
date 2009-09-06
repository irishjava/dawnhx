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

class GraphArc<T> implements haxe.rtti.Generic
{
	public var node:GraphNode<T>;
	public var cost:Float;
	
	public var next:GraphArc<T>;
	public var prev:GraphArc<T>;
	
	public function new(node:GraphNode<T>, cost:Float)
	{
		this.node = node;
		this.cost = cost;
		
		this.next = null;
		this.prev = null;
	}
	
	inline public function val():T
	{
		return node.val;
	}
	
	inline public function link(owner:GraphNode<T>):Void
	{
		#if debug
		if (owner == node)
			throw "target node equals current node";
		#end
		
		next = owner.arcList;
		if (owner.arcList != null) owner.arcList.prev = this;
		owner.arcList = this;
	}
	
	inline public function unlink(owner:GraphNode<T>):Void
	{
		#if debug
		if (owner == node)
			throw "target node equals current node";
		#end
		
		if (prev != null) prev.next = next;
		if (next != null) next.prev = prev;
		if (this == owner.arcList) owner.arcList = next;
	}
}