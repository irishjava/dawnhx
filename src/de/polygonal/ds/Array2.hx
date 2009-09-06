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

/**
 * A two-dimensional array.
 */
class Array2<T> implements haxe.rtti.Generic
{
	private var _v:Vector<T>;
	private var _w:Int;
	private var _h:Int;
	
	/**
	 * Create a two-dimensional array with a given width and height.
	 * The smallest possible size is 2x2.
	 *
	 * @param w The width  (equals #colums).
	 * @param h The height (equals #rows).
	 */
	public function new(w:Int, h:Int)
	{
		#if debug
		if (w < 2 || h < 2) throw "illegal size";
		#end
		
		_v = new Vector<T>((_w = w) * (_h = h));
	}
	
	/**
	 * Retrieve a value from a given x/y index.
	 *
	 * @param x The x index (column).
	 * @param y The y index (row).
	 *
	 * @return The value at the given x/y index.
	 */
	inline public function get(x:Int, y:Int):T
	{
		#if debug
		if (x < 0 || x >= _w) throw "x index out of bounds";
		if (y < 0 || y >= _h) throw "y index out of bounds";
		#end
		
		return _v[y * _w + x];
	}
	
	/**
	 * Assign a value to a given x/y index.
	 *
	 * @param x   The x index (column).
	 * @param y   The y index (row).
	 * @param obj The item to be written into the cell.
	 */
	inline public function set(x:Int, y:Int, val:T):Void
	{
		#if debug
		if (x < 0 || x >= _w) throw "x index out of bounds";
		if (y < 0 || y >= _h) throw "y index out of bounds";
		#end
		
		_v[y * _w + x] = val;
	}
	
	/**
	 * Indicates the width (#colums).
	 */
	inline public function getW():Int
	{
		return _w;
	}
	
	/**
	 * Assign a new width. This will resize the two-dimensional array.
	 * The minimum value is 2.
	 */
	inline public function setW(w:Int):Void
	{
		resize(w, _h);
	}
	
	/**
	 * Indicates the height (#rows).
	 */
	inline public function getH():Int
	{
		return _h;
	}
	
	/**
	 * Assign a new height. This will resize the two-dimensional array.
	 * The minimum value is 2.
	 */
	inline public function setH(h:Int):Void
	{
		resize(_w, h);
	}
	
	/**
	 * Extract a row from a given index.
	 *
	 * @param y The y index (row).
	 * @param output The output vector.
	 */
	inline public function getRow(y:Int, output:Vector<T>):Void
	{
		#if debug
		if (y < 0 || y >= _h) throw "y index out of bounds";
		#end
		
		var offset:Int = y * _w;
		for (x in 0..._w)
			output[x] = _v[offset + x];
	}
	
	/**
	 * Insert new values into a complete row of the two-dimensional array.
	 * The new row is truncated if it exceeds the existing width.
	 *
	 * @param y The y index (row).
	 * @param input The input vector.
	 */
	inline public function setRow(y:Int, input:Vector<T>):Void
	{
		#if debug
		if (y < 0 || y >= _h) throw "y index out of bounds";
		#end
		
		var offset:Int = y * _w;
		for (x in 0..._w)
			_v[offset + x] = input[x];
	}
	
	/**
	 * Extract a column from a given index.
	 *
	 * @param x The x index (column).
	 * @param output The output vector.
	 */
	inline public function getCol(x:Int, output:Vector<T>):Void
	{
		#if debug
		if (x < 0 || x >= _w) throw "x index out of bounds";
		#end

		for (i in 0..._h)
			output[i] = _v[i * _w + x];
	}
	
	/**
	 * Insert new values into a complete column of the two-dimensional array.
	 * The new column is truncated if it exceeds the existing height.
	 *
	 * @param y The x index (column).
	 * @param input The input vector.
	 */
	inline public function setCol(x:Int, input:Vector<T>):Void
	{
		#if debug
		if (x < 0 || x >= _w) throw "x index out of bounds";
		#end

		for (y in 0..._h)
			_v[y * _w + x] = input[y];
	}
	
	/**
	 * Assign a value to all cells of the two-dimensional array.
	 */
	inline public function assign(val:T):Void
	{
		for (i in 0..._w * _h) _v[i] = val;
	}
	
	/**
	 * Each cell is assigned an individual instance of the given class.
	 */
	inline public function factory(cl:Class<T>, args:Array<Dynamic> = null):Void
	{
		if (args == null) args = [];
		for (i in 0..._w * _h) _v[i] = Type.createInstance(cl, args);
	}
	
	/**
	 * Apply a function to each value.
	 * The function signature is: process(oldValue, x index, y index):newValue
	 */
	inline public function walk(process:T->Int->Int->T):Void
	{
		for (y in 0..._h)
		{
			for (x in 0..._w)
			{
				var i:Int = y * _w + x;
				_v[i] = process(_v[i], x, y);
			}
		}
	}

	/**
	 * Resize the two-dimensional array. If the new size is smaller than the existing size, values
	 * are lost because of truncation, otherwise all values are preserved.
	 * The minimum size is 2x2.
	 *
	 * @param w The new width (#cols).
	 * @param h The new height (#rows).
	 */
	inline public function resize(w:Int, h:Int):Void
	{
		#if debug
		if (w < 2 || h < 2) throw "illegal size";
		#end
		
		var t:Vector<T> = _v;
		_v = new Vector<T>(w * h, true);
		
		var xmin:Int = w < _w ? w : _w;
		var ymin:Int = h < _h ? h : _h;
		
		var x:Int, y:Int, t1:Int, t2:Int;
		for (y in 0...ymin)
		{
			t1 = y *  w;
			t2 = y * _w;
			
			for (x in 0...xmin)
				_v[t1 + x] = t[t2 + x];
		}
		
		_w = w;
		_h = h;
	}
	
	/**
	 * Move all columns by one column to the left. Columns are wrapped, so the column at index 0 is
	 * not lost but appended to the rightmost column.
	 */
	inline public function shiftW():Void
	{
		#if debug
		if (_w < 2) throw "shifting not possible";
		#end

		var t:T;
		var k:Int;
		for (y in 0..._h)
		{
			k = y * _w;
			t = _v[k];
			for (x in 1..._w)
				_v[k + x - 1] = _v[k + x];
			_v[k + _w - 1] = t;
		}
	}
	
	/**
	 * Move all columns by one column to the right. Columns are wrapped, so the column at the last
	 * index is not lost but appended to the leftmost column.
	 */
	inline public function shiftE():Void
	{
		#if debug
		if (_w < 2) throw "shifting not possible";
		#end

		var t:T;
		var x:Int;
		var k:Int;
		for (y in 0..._h)
		{
			k = y * _w;
			t = _v[k + _w - 1];
			x = _w - 1;
			while (x-- > 0)
				_v[k + x + 1] = _v[k + x];
			_v[k] = t;
		}
	}

	/**
	 * Move all rows up by one row. Rows are wrapped, so the first row is not lost but appended to
	 * bottommost row.
	 */
	inline public function shiftN():Void
	{
		#if debug
		if (_h < 2) throw "shifting not possible";
		#end

		var t:T;
		var k:Int = _h - 1;
		var l:Int = (_h - 1) * _w;
		for (x in 0..._w)
		{
			t = _v[x];
			for (y in 0...k)
				_v[y * _w + x] = _v[(y + 1) * _w + x];
			_v[l + x] = t;
		}
	}

	/**
	 * Move all rows down by one row. Rows are wrapped, so the last row is not lost but appended to
	 * the topmost row.
	 */
	inline public function shiftS():Void
	{
		#if debug
		if (_h < 2) throw "shifting not possible";
		#end

		var t:T;
		var y:Int;
		var k:Int = _h - 1;
		var l:Int = k * _w;
		for (x in 0..._w)
		{
			t = _v[l + x];
			y = k;
			while(y-- > 0) _v[(y + 1) * _w + x] = _v[y * _w + x];
			_v[x] = t;
		}
	}
	
	/**
	 * Fast swap operation.
	 *
	 * @param x0 The x index of the first value.
	 * @param y0 The y index of the first value.
	 * @param x1 The x index of the other value.
	 * @param y1 The y index of the other value.
	 */
	inline public function swap(x0:Int, y0:Int, x1:Int, y1:Int):Void
	{
		#if debug
		if (x0 < 0 || x0 >= _w) throw "x0 index out of bounds";
		if (y0 < 0 || y0 >= _h) throw "y0 index out of bounds";
		if (x1 < 0 || x1 >= _w) throw "x1 index out of bounds";
		if (y1 < 0 || y1 >= _h) throw "y1 index out of bounds";
		if (x0 == x1 && y0 == y1) throw "swap not possible";
		#end

		var i:Int = y0 * _w + x0;
		var j:Int = y1 * _w + x1;
		var t:T = _v[i];
		_v[i] = _v[j];
		_v[j] = t;
	}

	/**
	 * Append a row. If the new row doesn't match the current width, the inserted row is truncated
	 * or widened to match the existing width.
	 *
	 * @param input The input vector.
	 */
	inline public function appendRow(input:Vector<T>):Void
	{
		#if debug
		if (input.length != _w) throw "input vector does not match existing width";
		#end
		
		var t:Int = _w * _h++;
		for (x in 0..._w) _v[x + t] = input[x];
	}
	
	/**
	 * Append a column. If the new column doesn't match the current height, the inserted column is
	 * truncated or widened to match the existing height.
	 *
	 * @param input The input vector.
	 */
	inline public function appendCol(input:Vector<T>):Void
	{
		#if debug
		if (input.length != _h) throw "input vector does not match existing height";
		#end
		
		_v.length += _h;
		
		var i:Int = _h - 1;
		var j:Int = _h;
		var x:Int = _w;
		var y:Int = _v.length;
		while (y-- > 0)
		{
			if (++x > _w)
			{
				x = 0;
				j--;
				_v[y] = input[i--];
			}
			else
				_v[y] = _v[y - j];
		}
		_w++;
	}
	
	/**
	 * Prepend a row. If the new row doesn't match the current width, the inserted row is truncated
	 * or widened to match the existing width.
	 *
	 * @param input The input vector.
	 */
	inline public function prependRow(input:Vector<T>):Void
	{
		#if debug
		if (input.length != _w) throw "input vector does not match existing width";
		#end
		
		_v.length = _w * ++_h;
		
		var y:Int = _w * _h;
		while (y-- > _w)
			_v[y] = _v[y - _w];
		
		y++;
		
		while (y-- > 0)
			_v[y] = input[y];
	}
	
	/**
	 * Prepend a column. If the new column doesn't match the current height, the inserted column is
	 * truncated or widened to match the existing height.
	 *
	 * @param input The input vector.
	 */
	inline public function prependCol(input:Vector<T>):Void
	{
		#if debug
		if (input.length != _h) throw "input vector does not match existing height";
		#end
		
		_v.length += _h;
		
		var i:Int = _h - 1;
		var j:Int = _h;
		var x:Int = 0;
		var y:Int = _v.length;
		while (y-- > 0)
		{
			if (++x > _w)
			{
				x = 0;
				j--;
				_v[y] = input[i--];
			}
			else
				_v[y] = _v[y - j];
		}
		_w++;
	}
	
	/**
	 * Transpose operation (flip rows with cols and vice versa).
	 */
	inline public function transpose():Void
	{
		#if debug
		if (_w != _h) throw "need square matrix";
		#end
		
		for (y in 0..._h)
			for (x in y + 1..._w)
				swap(x, y, y, x);
	}
	
	/**
	 * Grant access to the linear vector which is used internally to store the data in the
	 * two-dimensional array. Useful for advanced operations.
	 */
	inline public function getArray():Vector<T>
	{
		return _v;
	}
	
	/**
	 * Fill the two-dimensional array with data from the given vector.
	 */
	inline public function setArray(input:Vector<T>):Void
	{
		#if debug
		if (input.length != _w * _h) throw "input vector does not match existing dimensions";
		#end
		
		var k:Int = _w * _h;
		for (i in 0...k)
			_v[i] = input[i];
	}
	
	/**
	 * Print out a string representing the current object.
	 * If the source is compiled with the -debug flag, all elements are dumped to screen.
	 *
	 * @return A string representing the current object.
	 */
	public function toString():String
	{
		#if debug
		var l:Int = 0;
		for (i in 0..._w * _h)
		{
			var s:String = Std.string(_v[i]);
			l = Std.int(Math.max(s.length, l));
		}

		var s:String = "\nArray2 (" + _w + "x" + _h + ")\n{";
		var offset:Int, value:T;
		for (y in 0..._h)
		{
			s += "\n\t";
			offset = y * _w;
			for (x in 0..._w)
			{
				value = _v[offset + x];
				s += "[" + StringTools.lpad(Std.string(value), " ", l) + "]";
			}
		}
		s += "\n}";
		return s;
		#else
		return "{Array2 " + getW() + "x" + getH() + "}";
		#end
	}

	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	/**
	 * Determine if the collection contains a given value.
	 *
	 * @param val The value to check against.
	 */
	public function contains(val:T):Bool
	{
		for (i in 0..._w * _h)
			if (_v[i] == val)
				return true;
		return false;
	}

	/**
	 * Clear all values.
	 */
	public function clear():Void
	{
		_v = new flash.Vector<T>(_w * _h, true);
	}
	
	/**
	 * Create an iterator pointing to the first value in the collection.
	 */
	public function iterator():Iterator<T>
	{
		return new Array2Iterator<T>(_v, _w * _h);
	}
	
	/**
	 * The total size of the two-dimensional array.
	 */
	public function size():Int
	{
		return _w * _h;
	}

	/**
	 * Check if the collection is empty.
	 */
	public function isEmpty():Bool
	{
		throw "unsupported operation";
		return false;
	}
	
	/**
	 * Convert the collection into an array.
	 */
	public function toArray():Array<T>
	{
		var t:Array<T> = new Array<T>();
		var k:Int = _w * _h;
		for (i in 0...k) t[i] = _v[i];
		return t;
	}
	
	/**
	 * Convert the collection into a vector.
	 */
	public function toVector():Vector<T>
	{
		var k:Int = _w * _h;
		var t:Vector<T> = new Vector<T>(k, true);
		for (i in 0...k) t[i] = _v[i];
		return t;
	}
	
	/**
	 * Shuffle the collection by applying the Fisher-Yates algorithm.
	 */
	public function shuffle():Void
	{
		var s:Int = _w * _h;
		var i:Int;
		var t:T;
		while (s > 1)
		{
			s--;
			i = Std.int(Math.random() * s);
			t     = _v[s];
			_v[s] = _v[i];
			_v[i] = t;
		}
	}
	
	/**
	 * Clone the data structure.
	 * In order to create a "deep-copy" you need to pass a function reference responsible for
	 * duplicating each value. If you pass null, copying values is done by assignment, thus assuming
	 * the values are primitives.
	 */
	public function clone(copier:T->T):Collection<T>
	{
		var copy:Array2<T> = new Array2<T>(getW(), getH());
		if (copier == null)
			copy.setArray(toVector());
		else
		{
			for (y in 0...getH())
				for (x in 0...getW())
					copy.set(x, y, copier(get(x, y)));
		}
		
		return cast copy;
	}
}

class Array2Iterator<T> implements haxe.rtti.Generic
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