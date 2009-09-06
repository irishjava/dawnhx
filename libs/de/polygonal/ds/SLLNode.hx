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

class SLLNode<T> implements haxe.rtti.Generic
{
	public var val:T;

	public var next:SLLNode<T>;
	
	var _list:SLL<T>;
	
	inline public function hasNext():Bool
	{
		return next != null;
	}
	
	/**
	 * Access the value of the next node.
	 */
	inline public function nextVal():T
	{
		#if debug
		if (!hasNext()) throw "node does not exist";
		#end
		
		return next.val;
	}
	
	/**
	 * A reference to the list that this node is contained in.
	 */
	inline public function getList():SLL<T>
	{
		return _list;
	}
	
	/**
	 * Remove this node from the list.
	 */
	inline public function remove():Void
	{
		_list.remove(this);
	}
	
	inline public function insertAfter(node:SLLNode<T>):Void
	{
		node.next = next;
		next = node;
	}
	
	public function new(val:Null<T>, list:SLL<T>)
	{
		this.val = val;
		_list = list;
	}
}