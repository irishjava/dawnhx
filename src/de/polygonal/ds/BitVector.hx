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

import flash.utils.ByteArray;
import flash.Vector;

class BitVector
{
	private var _bits:Vector<Int>;
	private var _arrSize:Int;
	private var _bitSize:Int;
	
	public function new(size:Int)
	{
		_bits = null;
		_bitSize = 0;
		_arrSize = 0;
		
		resize(size);
	}
	
	inline public function size():Int
	{
		return _bitSize;
	}
	
	inline public function bucketSize():Int
	{
		return _arrSize;
	}
	
	inline public function hasBit(i:Int):Bool
	{
		#if debug
		if (i >= size()) throw "index out of bounds";
		#end
		
		return ((_bits[i >> 5] & (1 << (i & 31))) >> (i & 31)) != 0;
	}
	
	inline public function setBit(i:Int):Void
	{
		#if debug
		if (i >= size()) throw "index out of bounds";
		#end
		
		_bits[i >> 5] = _bits[i >> 5] | (1 << (i & 31));
	}
	
	inline public function clrBit(i:Int):Void
	{
		#if debug
		if (i >= size()) throw "index out of bounds";
		#end
		
		_bits[i >> 5] = _bits[i >> 5] & (~(1 << (i & 31)));
	}
	
	inline public function clrAll():Void
	{
		for (i in 0..._arrSize) _bits[i] = 0;
	}
	
	inline public function setAll():Void
	{
		var f:Int = Bits.BIT_ALL;
		for (i in 0..._arrSize) _bits[i] = f;
	}
	
	public function resize(size:Int):Void
	{
		if (_bitSize == size) return;
		
		//convert bit-size to integer-size
		var arrSize:Int = size >> 5;
		if ((size & 31) > 0) arrSize++;
		
		if (_bits == null)
			_bits = new Vector<Int>(arrSize, true);
		else
		if (arrSize < _arrSize)
		{
			var t:Vector<Int> = new Vector<Int>(arrSize, true);
			for (i in 0...arrSize) t[i] = _bits[i];
			_bits = t;
		}
		else
		{
			if (_arrSize != arrSize)
			{
				var t:Vector<Int> = new Vector<Int>(arrSize, true);
				for (i in 0..._arrSize) t[i] = _bits[i];
				_bits = t;
			}
		}
		
		_bitSize = size;
		_arrSize = arrSize;
	}
	
	public function getByteArray():ByteArray
	{
		var b:ByteArray = new ByteArray();
		for (i in 0..._arrSize)
			b.writeInt(_bits[i]);
		b.position = 0;
		return b;
	}
	
	public function setByteArray(b:ByteArray):Void
	{
		_arrSize = (b.length - (b.length % 4)) >> 2;
		_bitSize = _arrSize << 5;
		_bits = new Vector<Int>(_arrSize, true);
		b.position = 0;
		for (i in 0..._arrSize)
			_bits[i] = b.readInt();
	}
	
	public function toString():String
	{
		#if debug
		var s:String = "BitVector, size: " + _bitSize + "\n{\n\t";
		for (i in 0..._bitSize)
			s += hasBit(i) ? "1" : "0";
			
		return s + "\n}";
		#else
		return "{BitVector, size: " + _bitSize + "}";
		#end
	}
	
	public function clone():BitVector
	{
		var copy:BitVector = new BitVector(_bitSize);
		for (i in 0...size())
		{
			if (hasBit(i))
				copy.setBit(i);
		}
		return copy;
	}
}