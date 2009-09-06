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

class Array3<T> implements haxe.rtti.Generic
{
	private var _v:Vector<T>;
	private var _w:Int;
	private var _h:Int;
	private var _d:Int;

	public function new(w:Int, h:Int, d:Int)
	{
		#if debug
		if (w < 1 || h < 1 || d < 1) throw "illegal size";
		#end

		_v = new Vector<T>((_w = w) * (_h = h) * (_d = d));
	}

	inline public function get(x:Int, y:Int, z:Int):T
	{
		#if debug
		if (x < 0 || x > _w) throw "x index out of bounds";
		if (y < 0 || y > _h) throw "y index out of bounds";
		if (z < 0 || z > _d) throw "z index out of bounds";
		#end

		return _v[(z * _w * _h) + (y * _w) + x];
	}

	inline public function set(x:Int, y:Int, z:Int, val:T):Void
	{
		#if debug
		if (x < 0 || x > _w) throw "x index out of bounds";
		if (y < 0 || y > _h) throw "y index out of bounds";
		if (z < 0 || z > _d) throw "z index out of bounds";
		#end

		_v[(z * _w * _h) + (y * _w) + x] = val;
	}

	inline public function getW():Int
	{
		return _w;
	}

	inline public function setW(w:Int):Void
	{
		resize(w, _h, _d);
	}

	inline public function getH():Int
	{
		return _h;
	}

	inline public function setH(h:Int):Void
	{
		resize(_w, h, _d);
	}
	
	inline public function getD():Int
	{
		return _d;
	}
	
	inline public function setD(d:Int):Void
	{
		resize(_w, _h, d);
	}

	inline public function getLayer(z:Int):Array2<T>
	{
		var a2:Array2<T> = new Array2<T>(_w, _h);
		var offset:Int =  z * _w * _h;
		for (x in 0..._w)
			for (y in 0..._h)
				a2.set(x, y, _v[offset + (y * _w) + x]);
		
		return a2;
	}
	
	inline public function getRow(z:Int, y:Int, output:Vector<T>):Void
	{
		#if debug
		if (y < 0 || y > _h) throw "y index out of bounds";
		if (z < 0 || z > _d) throw "z index out of bounds";
		#end

		var offset:Int = (z * _w * _h) + (y * _w);
		for (x in 0..._w) output[x] = _v[offset + x];
	}

	inline public function setRow(z:Int, y:Int, input:Vector<T>):Void
	{
		#if debug
		if (y < 0 || y > _h) throw "y index out of bounds";
		if (z < 0 || z > _d) throw "z index out of bounds";
		#end
		
		var offset:Int = (z * _w * _h) + (y * _w);
		for (x in 0..._w) _v[offset + x] = input[x];
	}

	inline public function getCol(z:Int, x:Int, output:Vector<T>):Void
	{
		#if debug
		if (x < 0 || x > _w) throw "x index out of bounds";
		if (z < 0 || z > _d) throw "z index out of bounds";
		#end
		
		var offset:Int = z * _w * _h;
		for (i in 0..._h) output[i] = _v[offset + (i * _w + x)];
	}

	inline public function setCol(z:Int, x:Int, input:Vector<T>):Void
	{
		#if debug
		if (x < 0 || x > _w) throw "x index out of bounds";
		if (z < 0 || z > _d) throw "z index out of bounds";
		#end
		var offset:Int = z * _w * _h;
		for (i in 0..._h) _v[offset + (i * _w + x)] = input[i];
	}
	
	inline public function getPile(x:Int, y:Int, output:Vector<T>):Void
	{
		var offset1:Int = _w * _h;
		var offset2:Int = (y * _w + x);
		for (z in 0..._d) output[z] = _v[z * offset1 + offset2];
	}
	
	inline public function setPile(x:Int, y:Int, input:Vector<T>):Void
	{
		var offset1:Int = _w * _h;
		var offset2:Int = (y * _w + x);
		for (z in 0..._d)
			_v[z * offset1 + offset2] = input[z];
	}
	
	inline public function assign(val:T):Void
	{
		for (i in 0..._w * _h * _d) _v[i] = val;
	}
	
	inline public function factory(cl:Class<T>, args:Array<Dynamic> = null):Void
	{
		if (args == null) args = [];
		for (i in 0..._w * _h * _d) _v[i] = Type.createInstance(cl, args);
	}

	inline public function walk(process:T->Int->Int->Int->T):Void
	{
		for (z in 0..._d)
		{
			for (y in 0..._h)
			{
				for (x in 0..._w)
				{
					var i:Int = z * _w * _h + y * _w + x;
					_v[i] = process(_v[i], x, y, z);
				}
			}
		}
	}

	inline public function resize(w:Int, h:Int, d:Int):Void
	{
		#if debug
		if (w < 1 || h < 1 || d < 1) throw "illegal size";
		#end

		var t:Vector<T> = _v;
		_v = new Vector<T>(w * h * d);

		var xmin:Int = w < _w ? w : _w;
		var ymin:Int = h < _h ? h : _h;
		var zmin:Int = d < _d ? d : _d;

		var x:Int, y:Int, z:Int, t1:Int, t2:Int, t3:Int, t4:Int;
		for (z in 0...zmin)
		{
			t1 = z *  w  * h;
			t2 = z * _w * _h;
			
			for (y in 0...ymin)
			{
				t3 = y *  w;
				t4 = y * _w;
				
				for (x in 0...xmin)
					_v[t1 + t3 + x] = t[t2 + t4 + x];
			}
		}
		
		_w = w;
		_h = h;
		_d = d;
	}

	inline public function swap(x0:Int, y0:Int, z0:Int, x1:Int, y1:Int, z1:Int):Void
	{
		#if debug
		if (x0 < 0 || x0 > _w) throw "x0 index out of bounds";
		if (y0 < 0 || y0 > _h) throw "y0 index out of bounds";
		if (z0 < 0 || z0 > _d) throw "z0 index out of bounds";
		if (x1 < 0 || x1 > _w) throw "x1 index out of bounds";
		if (y1 < 0 || y1 > _h) throw "y1 index out of bounds";
		if (z1 < 0 || z1 > _d) throw "z1 index out of bounds";
		if (x0 == x1 && y0 == y1) throw "swap not possible";
		#end

		var i:Int = (z0 * _w * _h) + (y0 * _w) + x0;
		var j:Int = (z1 * _w * _h) + (y1 * _w) + x1;
		
		var t:T = _v[i];
		_v[i] = _v[j];
		_v[j] = t;
	}

	inline public function getArray():Vector<T>
	{
		return _v;
	}

	inline public function setArray(input:Vector<T>):Void
	{
		#if debug
		if (input.length != size()) throw "input vector does not match existing dimensions";
		#end
		
		var k:Int = _w * _h * _d;
		for (i in 0...k) _v[i] = input[i];
	}

	public function toString():String
	{
		return "Array3, dimensions:" + _w + "x" + _h + "x" + _d + ")";
	}

	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/

	public function contains(val:T):Bool
	{
		for (i in 0..._w * _h * _d)
			if (_v[i] == val)
				return true;
		return false;
	}

	public function clear():Void
	{
		_v = new flash.Vector<T>(_w * _h * _d, true);
	}

	public function iterator():Iterator<T>
	{
		return new Array3Iterator<T>(_v, _w * _h * _d);
	}

	public function size():Int
	{
		return _w * _h * _d;
	}

	public function isEmpty():Bool
	{
		throw "unsupported operation";
		return false;
	}

	public function toArray():Array<T>
	{
		var t:Array<T> = new Array<T>();
		var k:Int = _w * _h * _d;
		for (i in 0...k) t[i] = _v[i];
		return t;
	}

	public function toVector():Vector<T>
	{
		var t:Vector<T> = new Vector<T>();
		var k:Int = _w * _h * _d;
		for (i in 0...k) t[i] = _v[i];
		return t;
	}

	public function shuffle():Void
	{
		var s:Int = _w * _h * _d, i:Int, t:T;
		while (s > 1)
		{
			s--;
			i = Std.int(Math.random() * s);
			t     = _v[s];
			_v[s] = _v[i];
			_v[i] = t;
		}
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		var copy:Array3<T> = new Array3<T>(_w, _h, _d);
		if (copier == null)
			copy.setArray(toVector());
		else
		{
			for (z in 0..._d)
				for (y in 0..._h)
					for (x in 0..._w)
					copy.set(x, y, z, copier(get(x, y, z)));
		}
		
		return cast copy;
	}
}

class Array3Iterator<T> implements haxe.rtti.Generic
{
	private var _v:Vector<T>;
	private var _i:Int;
	private var _s:Int;

	public function new(v:Vector<T>, s:Int)
	{
		_v = v;
		_i = 0;
		_s = s;
	}

	public function hasNext():Bool
	{
		return _i < _s;
	}

	public function next():T
	{
		return _v[_i++];
	}
}