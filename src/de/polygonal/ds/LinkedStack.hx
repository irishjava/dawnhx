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

import flash.Vector;

class LinkedStack<T>
{
	private var _list:DLL<T>;
	
	public function new(?list:DLL<T> = null)
	{
		if (list == null)
			_list = new DLL<T>();
		else
			_list = list;
	}

	inline public function peek():T
	{
		return _list.tail().val;
	}

	inline public function push(val:T):Void
	{
		_list.append(val);
	}

	inline public function pop():T
	{
		return _list.removeTail();
	}
	
	inline public function assign(val:T):Void
	{
		_list.assign(val);
	}
	
	inline public function factory(cl:Class<T>, args:Array<Dynamic> = null):Void
	{
		_list.factory(cl, args);
	}

	public function toString():String
	{
		#if debug
		var s:String = "\nLinkedStack, size: " + size() + "\n{\n";
		for (i in this) s += "\t" + i + "\n";
		return s += "}";
		#else
		return "{LinkedStack, size: " + size() + "}";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:T):Bool
	{
		return _list.contains(val);
	}
	
	public function clear():Void
	{
		_list.clear();
	}
	
	public function iterator():Iterator<T>
	{
		return _list.iterator();
	}
	
	public function size():Int
	{
		return _list.size();
	}
	
	public function isEmpty():Bool
	{
		return _list.isEmpty();
	}
	
	public function toArray():Array<T>
	{
		return _list.toArray();
	}
	
	public function toVector():Vector<T>
	{
		return _list.toVector();
	}
	
	public function shuffle():Void
	{
		_list.shuffle();
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		var copy:LinkedStack<T> = new LinkedStack();
		for (i in this) copy.push(i);
		return copy;
	}
}