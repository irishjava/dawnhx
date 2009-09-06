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

class ArrayedStack<T> implements haxe.rtti.Generic
{
	private var _v:Vector<T>;
	private var _size:Int;
	private var _top:Int;

	public function new(size:Int)
	{
		_size = size;
		_v = new Vector<T>(_size, true);
		_top = 0;
	}

	inline public function maxSize():Int
	{
		return _size;
	}

	inline public function peek():T
	{
		#if debug
		if (_top == 0) throw "stack is empty";
		#end
		return _v[_top - 1];
	}

	inline public function push(val:T):Void
	{
		#if debug
		if (_size == _top) throw "stack is full";
		#end

		_v[_top++] = val;
	}

	inline public function pop():T
	{
		#if debug
		if (_top == 0) throw "stack is empty";
		#end

		return _v[--_top];
	}

	inline public function getAt(i:Int):T
	{
		#if debug
		if (_top == 0) throw "stack is empty";
		if (i >= _top) throw "index out of bounds";
		#end

		return _v[i];
	}

	inline public function setAt(i:Int, val:T):Void
	{
		#if debug
		if (i >= _top) throw "index out of bounds";
		#end
		
		_v[i] = val;
	}
	
	inline public function assign(val:T):Void
	{
		while (_top < _size) _v[_top++] = val;
	}
	
	inline public function factory(cl:Class<T>, args:Array<Dynamic> = null):Void
	{
		if (args == null) args = [];
		while (_top < _size) _v[_top++] = Type.createInstance(cl, args);
	}

	inline public function walk(process:T->Int->T):Void
	{
		for (i in 0..._top)
			_v[i] = process(_v[i], i);
	}
	
	public function toString():String
	{
		#if debug
		var s:String = "\nArrayedStack (" + _top + ")\n{\n";
		
		var i:Int = _top - 1;
		var j:Int = 0;
		while (i >= 0)
			s += "\t" + j++ + "\t-> " + _v[i--] + "\n";
		return s + "}";
		#else
		return "{ArrayedStack, size: " + size() + "}";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:T):Bool
	{
		for (i in 0..._top)
		{
			if (_v[i] == val)
				return true;
		}
		return false;
	}
	
	public function clear():Void
	{
		_top = 0;
	}

	public function iterator():Iterator<T>
	{
		return new ArrayedStackIterator<T>(_v, _top);
	}

	public function size():Int
	{
		return _top;
	}

	public function isEmpty():Bool
	{
		return _top == 0;
	}

	public function toArray():Array<T>
	{
		var a:Array<T> = new Array<T>();
		for (i in 0..._top)
			a[i] = _v[i];
		return a;
	}

	public function toVector():Vector<T>
	{
		var v:Vector<T> = new Vector<T>(size(), true);
		for (i in 0..._top)
			v[i] = _v[i];
		return v;
	}

	public function shuffle():Void
	{
		var s:Int = _top, i:Int, t:T;
		while (s > 1)
		{
			i = Std.int(Math.random() * (--s));
			t         = _v[s];
			_v[s] = _v[i];
			_v[i] = t;
		}
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		var copy:ArrayedStack<T> = new ArrayedStack<T>(_size);
		if (copier == null)
		{
			for (i in 0...size())
				copy.push(getAt(i));
		}
		else
		{
			for (i in 0...size())
				copy.push(copier(getAt(i)));
		}
		
		return cast copy;
	}
}

class ArrayedStackIterator<T> implements haxe.rtti.Generic
{
	private var _v:Vector<T>;
	private var _i:Int;

	public function new(v:Vector<T>, s:Int)
	{
		_v = v;
		_i = s - 1;
	}

	public function hasNext():Bool
	{
		return _i >= 0;
	}

	public function next():T
	{
		return _v[_i--];
	}
}