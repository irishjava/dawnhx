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

package de.polygonal.ds.mem;

import flash.Memory;
import flash.utils.ByteArray;
import flash.Vector;

class IntMemory extends MemoryAccess
{
	public function new()
	{
		super();
	}
	
	inline public function get(i:Int):Int
	{
		return Memory.getI32(getIndex(i));
	}
	
	inline public function set(i:Int, val:Int):Void
	{
		Memory.setI32(getIndex(i), val);
	}
	
	inline public function purge():Void
	{
		for (i in 0..._size)
			set(i, 0);
		
		_memory.purge();
		_memory = null;
	}
	
	inline public function toByteArrayRange(min:Int, max:Int):ByteArray
	{
		#if debug
		if (max - min <= 0 || min < 0 || max >= size()) throw "invalid range";
		#end
		
		var b:ByteArray = new ByteArray();
		var addr:Int = _offset + (min << 2);
		
		for (i in min...max)
		{
			b.writeInt(Memory.getI32(addr));
			addr += 4;
		}
		b.position = 0;
		return b;
	}
	
	inline public function toByteArray():ByteArray
	{
		var b:ByteArray = new ByteArray();
		var addr:Int = _offset;
		for (i in 0...size())
		{
			b.writeInt(Memory.getI32(addr));
			addr += 4;
		}
		b.position = 0;
		return b;
	}
	
	inline public function toVectorRange(min:Int, max:Int):Vector<Int>
	{
		#if debug
		if (max - min <= 0 || min < 0 || max >= size()) throw "invalid range";
		#end
		
		var v:Vector<Int> = new Vector<Int>(max - min, true);
		var addr:Int = _offset + (min << 2);
		for (i in 0...max - min)
		{
			v[i] = Memory.getI32(addr);
			addr += 4;
		}
		return v;
	}
	
	inline public function toVector():Vector<Int>
	{
		var v:Vector<Int> = new Vector<Int>(size(), true);
		var addr:Int = _offset;
		for (i in 0...size())
		{
			v[i] = Memory.getI32(addr);
			addr += 4;
		}
		return v;
	}
	
	inline public function fromVector(input:Vector<Int>):Void
	{
		#if debug
		if (input.length != size())
			throw "invalid input vector length";
		#end
		
		var offset:Int = _offset;
		for (i in 0...input.length)
		{
			Memory.setI32(offset + (i << 2), input[i]);
		}
	}
	
	inline private function getIndex(i:Int):Int
	{
		#if debug
		if (i < 0 || i > _size) throw "index out of bounds";
		if (_memory == null) throw "memory was deallocated";
		#end
		
		return _offset + (i << 2);
	}
	
	override public function toString():String
	{
		var s:String = "IntMemory " + _memory.b + "..." + _memory.e + "\n{\n";
		for (i in 0..._size)
			s += "\t" + i + " -> " + get(i) + "\n";
		return s + "}";
	}
	
	override private function getBitSize():Int
	{
		return 32;
	}
}