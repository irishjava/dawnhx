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

package de.polygonal.ds.mem.complex;

import de.polygonal.ds.mem.complex.accessor.DoubleMemoryAccessor;
import flash.Memory;
import flash.Vector;
import de.polygonal.ds.Collection;

class MemStackDouble extends DoubleMemoryAccessor
{
	private var _top:Int;

	public function new(size:Int)
	{
		super(size);
		_top = 0;
	}

	inline public function maxSize():Int
	{
		return _size;
	}

	inline public function peek():Float
	{
		#if debug
		if (_top == 0) throw "stack is empty";
		#end
		
		return memget(_top - 1);
	}

	inline public function push(val:Float):Void
	{
		#if debug
		if (_size == _top) throw "stack is full";
		#end
		
		memset(_top++, val);
	}

	inline public function pop():Float
	{
		#if debug
		if (_top == 0) throw "stack is empty";
		#end

		return memget(--_top);
	}

	inline public function getAt(i:Int):Float
	{
		#if debug
		if (_top == 0) throw "stack is empty";
		if (i >= _top) throw "index out of bounds";
		#end

		return memget(i);
	}

	inline public function setAt(i:Int, val:Float):Void
	{
		#if debug
		if (i >= _top) throw "index out of bounds";
		#end
		
		memset(i, val);
	}

	inline public function walk(process:Float->Int->Float):Void
	{
		for (i in 0..._top)
			memset(i, process(memget(i), i));
	}
	
	override public function toString():String
	{
		#if debug
		var s:String = "\nMemStackDouble (" + _top + ")\n{\n";
		
		var i:Int = _top - 1;
		var j:Int = 0;
		while (i >= 0)
			s += "\t" + j++ + "\t-> " + memget(i--) + "\n";
		return s + "}";
		#else
		return "{MemStackDouble, size: " + size() + "}";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:Float):Bool
	{
		for (i in 0..._top)
		{
			if (memget(i) == val)
				return true;
		}
		return false;
	}
	
	override public function clear():Void
	{
		_top = 0;
	}

	public function iterator():Iterator<Float>
	{
		return new MemStackDoubleIterator<Float>(_offset, _top);
	}

	override public function size():Int
	{
		return _top;
	}

	public function isEmpty():Bool
	{
		return _top == 0;
	}

	public function toArray():Array<Float>
	{
		var a:Array<Float> = new Array<Float>();
		for (i in 0..._top)
			a[i] = memget(i);
		return a;
	}

	public function toVector():Vector<Float>
	{
		var v:Vector<Float> = new Vector<Float>(size(), true);
		for (i in 0..._top)
			v[i] = memget(i);
		return v;
	}

	public function shuffle():Void
	{
		var s:Int = _top, i:Int, t:Int;
		while (s > 1)
		{
			i = Std.int(Math.random() * (--s));
			memswp(s, i);
		}
	}
	
	public function clone(copier:Float->Float):Collection<Float>
	{
		var copy:MemStackDouble = new MemStackDouble(_size);
		for (i in 0...size()) copy.push(getAt(i));
		return cast copy;
	}
}

class MemStackDoubleIterator<T>
{
	private var _offset:Int;
	private var _i:Int;

	public function new(offset:Int, s:Int)
	{
		_offset= offset;
		_i = s - 1;
	}

	public function hasNext():Bool
	{
		return _i >= 0;
	}

	public function next():Float
	{
		return Memory.getDouble(_offset + ((_i--) << 3));
	}
}