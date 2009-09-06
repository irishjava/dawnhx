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

import de.polygonal.ds.Bits;
import de.polygonal.ds.BitVector;
import de.polygonal.ds.mem.IntMemory;
import de.polygonal.ds.mem.MemoryManager;
import flash.Memory;
import flash.utils.ByteArray;
import flash.Vector;

class BitMemory extends MemoryAccess
{
	public function new(bitSize:Int)
	{
		super();
		_size = bitSize;
	}
	
	override public function setMemory(memory:MemoryArea):Void
	{
		var bitSize:Int = _size;
		super.setMemory(memory);
		_size = bitSize;
	}
	
	inline public function has(i:Int):Bool
	{
		return ((Memory.getI32(getIndex(i)) & (1 << (i & 31))) >> (i & 31)) != 0;
	}
	
	inline public function set(i:Int):Void
	{
		var idx:Int = getIndex(i);
		Memory.setI32(idx, Memory.getI32(idx) | (1 << (i & 31)));
	}
	
	inline public function clr(i:Int):Void
	{
		var idx:Int = getIndex(i);
		Memory.setI32(idx, Memory.getI32(idx) & ~(1 << (i & 31)));
	}
	
	inline public function clrAll():Void
	{
		for (i in 0..._size) Memory.setI32(getIndex(i), 0);
	}
	
	inline public function setAll():Void
	{
		for (i in 0..._size) Memory.setI32(getIndex(i), Bits.BIT_ALL);
	}
	
	inline public function purge():Void
	{
		clrAll();
		
		_memory.purge();
		_memory = null;
	}
	
	inline public function toByteArray():ByteArray
	{
		var b:ByteArray = new ByteArray();
		var addr:Int = _offset;
		for (i in 0...size() >> 5)
		{
			b.writeInt(Memory.getI32(addr));
			addr += 4;
		}
		b.position = 0;
		return b;
	}
	
	inline public function toBitVector():BitVector
	{
		var v:BitVector = new BitVector(size());
		v.setByteArray(toByteArray());
		return v;
	}
	
	inline private function getIndex(i:Int):Int
	{
		#if debug
		if (i < 0 || i > _size) throw "index out of bounds";
		if (_memory == null) throw "memory was deallocated";
		#end
		
		return _offset + ((i >> 5) << 2);
	}
	
	override public function toString():String
	{
		#if debug
		var s:String = "BitMemory " + _memory.b + "..." + _memory.e + "\n{\n\t";
		for (i in 0..._size)
			s += has(i) ? "1" : "0";
		return s + "\n}";
		#else
		return "{BitMemory " + _memory.b + "..." + _memory.e + "}";
		#end
	}
	
	override private function getBitSize():Int
	{
		return 32;
	}
}