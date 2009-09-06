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

import de.polygonal.ds.Collection;
import de.polygonal.ds.mem.complex.accessor.DoubleMemoryAccessor;
import de.polygonal.ds.mem.DoubleMemory;
import de.polygonal.ds.mem.MemoryAccess;
import de.polygonal.ds.mem.MemoryManager;
import flash.Memory;
import flash.Vector;

class MemArray2Double extends DoubleMemoryAccessor
{
	private var _w:Int;
	private var _h:Int;

	public function new(w:Int, h:Int)
	{
		#if debug
		if (w < 2 || h < 2) throw "illegal size";
		#end
		
		super(w * h);
		
		_w = w;
		_h = h;
	}
	
	inline public function get(x:Int, y:Int):Float
	{
		#if debug
		if (x < 0 || x >= _w) throw "x index out of bounds";
		if (y < 0 || y >= _h) throw "y index out of bounds";
		#end
		
		return memget(y * _w + x);
	}

	inline public function set(x:Int, y:Int, val:Float):Void
	{
		#if debug
		if (x < 0 || x >= _w) throw "x index out of bounds";
		if (y < 0 || y >= _h) throw "y index out of bounds";
		#end
		
		memset(y * _w + x, val);
	}

	inline public function getW():Int
	{
		return _w;
	}

	inline public function getH():Int
	{
		return _h;
	}
	
	inline public function getRow(y:Int, output:DoubleMemory):Void
	{
		#if debug
		if (y < 0 || y >= _h) throw "y index out of bounds";
		#end
		
		for (x in 0..._w) output.set(x, get(x, y));
	}
	
	inline public function setRow(y:Int, input:DoubleMemory):Void
	{
		#if debug
		if (y < 0 || y >= _h) throw "y index out of bounds";
		#end
		
		for (x in 0..._w) set(x, y, input.get(x));
	}
	
	inline public function getCol(x:Int, output:DoubleMemory):Void
	{
		#if debug
		if (x < 0 || x >= _w) throw "x index out of bounds";
		#end
		
		for (y in 0..._h) output.set(y, get(x, y));
	}
	
	inline public function setCol(x:Int, input:DoubleMemory):Void
	{
		#if debug
		if (x < 0 || x >= _w) throw "x index out of bounds";
		#end
		
		for (y in 0..._h) set(x, y, input.get(y));
	}
	
	inline public function assign(val:Float):Void
	{
		for (i in 0..._w * _h) memset(i, val);
	}

	inline public function walk(process:Float->Int->Int->Float):Void
	{
		for (y in 0..._h)
		{
			for (x in 0..._w)
			{
				var addr:Int = y * _w + x;
				memset(addr, process(memget(addr), x, y));
			}
		}
	}

	inline public function swap(x0:Int, y0:Int, x1:Int, y1:Int):Void
	{
		#if debug
		if (x0 < 0 || x0 > _w) throw "x0 index out of bounds";
		if (y0 < 0 || y0 > _h) throw "y0 index out of bounds";
		if (x1 < 0 || x1 > _w) throw "x1 index out of bounds";
		if (y1 < 0 || y1 > _h) throw "y1 index out of bounds";
		if (x0 == x1 && y0 == y1) throw "swap not possible";
		#end
		
		memswp(y0 * _w + x0, y1 * _w + x1);
	}
	
	inline public function transpose():Void
	{
		#if debug
		if (_w != _h) throw "need square matrix";
		#end
		
		for (y in 0..._h)
			for (x in y + 1..._w)
				swap(x, y, y, x);
	}
	
	inline public function shiftW():Void
	{
		#if debug
		if (_w < 2) throw "shifting not possible";
		#end
		
		var t:Float;
		var k:Int;
		for (y in 0..._h)
		{
			k = y * _w;
			t = memget(k);
			for (x in 1..._w)
				memset(k + x - 1, memget(k + x));
			memset(k + _w - 1, t);
		}
	}
	
	inline public function shiftE():Void
	{
		#if debug
		if (_w < 2) throw "shifting not possible";
		#end
		
		var t:Float;
		var x:Int;
		var k:Int;
		for (y in 0..._h)
		{
			k = y * _w;
			t = memget(k + _w - 1);
			x = _w - 1;
			while (x-- > 0)
				memset(k + x + 1, memget(k + x));
			memset(k, t);
		}
	}

	inline public function shiftN():Void
	{
		#if debug
		if (_h < 2) throw "shifting not possible";
		#end
		
		var t:Float;
		var k:Int = _h - 1;
		var l:Int = (_h - 1) * _w;
		for (x in 0..._w)
		{
			t = memget(x);
			for (y in 0...k)
				memset(y * _w + x, memget((y + 1) * _w + x));
			memset(l + x, t);
		}
	}

	inline public function shiftS():Void
	{
		#if debug
		if (_h < 2) throw "shifting not possible";
		#end
		
		var t:Float;
		var y:Int;
		var k:Int = _h - 1;
		var l:Int = k * _w;
		for (x in 0..._w)
		{
			t = memget(l + x);
			y = k;
			while(y-- > 0)
				memset((y + 1) * _w + x, memget(y * _w + x));
			memset(x, t);
		}
	}
	
	inline public function setArray(input:DoubleMemory):Void
	{
		#if debug
		if (input.size() != _w * _h) throw "input vector does not match existing dimensions";
		#end
		
		var k:Int = _w * _h;
		for (i in 0...k)
			memset(i, input.get(i));
	}
	
	override public function toString():String
	{
		#if debug
		var l:Int = 0;
		for (i in 0..._w * _h)
		{
			var s:String = Std.string(memget(i));
			l = Std.int(Math.max(s.length, l));
		}
		
		var s:String = "\nMemArray2Double (" + _w + "x" + _h + ")\n{";
		for (y in 0..._h)
		{
			s += "\n\t";
			for (x in 0..._w)
			{
				s += "[" + StringTools.lpad(Std.string(get(x, y)), " ", l) + "]";
			}
		}
		s += "\n}";
		return s;
		#else
		return "{MemArray2Double " + getW() + "x" + getH() + "}";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:Float):Bool
	{
		for (i in 0..._w * _h)
		{
			if (memget(i) == val)
				return true;
		}
		return false;
	}

	public function iterator():Iterator<Float>
	{
		return new MemArray2DoubleIterator<Float>(_offset, _w * _h);
	}
	
	public function isEmpty():Bool
	{
		return false;
	}
	
	public function toArray():Array<Float>
	{
		var a:Array<Float> = new Array<Float>();
		for (i in 0..._w * _h)
			a[i] = memget(i);
		return a;
	}
	
	public function toVector():flash.Vector<Float>
	{
		var k = _w * _h;
		var v:Vector<Float> = new Vector<Float>(k, true);
		for (i in 0...k)
			v[i] = memget(i);
		return v;
	}
	
	public function shuffle():Void
	{
		var s:Int = _w * _h;
		var i:Int;
		var t:Float;
		var x:Int;
		var y:Int;
		while (s > 1)
		{
			s--;
			i = Std.int(Math.random() * s);
			memswp(s, i);
		}
	}
	
	public function clone(copier:Float->Float):Collection<Float>
	{
		var copy = new MemArray2Double(_w, _h);
		for (y in 0..._h)
			for (x in 0..._w)
				copy.set(x, y, get(x, y));
		return copy;
	}
}

class MemArray2DoubleIterator<T>
{
	private var _offset:Int;
	private var _i:Int;
	private var _s:Int;
	
	public function new(offset:Int, s:Int)
	{
		_offset = offset;
		_i = 0;
		_s = s;
	}

	public function hasNext():Bool
	{
		return _i < _s;
	}

	public function next():T
	{
		return untyped Memory.getDouble(_offset + ((_i++) << 3));
	}
}