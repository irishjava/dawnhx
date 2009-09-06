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

class MemoryAccess
{
	private var _offset:Int;
	private var _size:Int;
	private var _memory:MemoryArea;
	
	public function new()
	{
		_offset = 0;
		_size = 0;
		_memory = null;
	}
	
	public function setMemory(memory:MemoryArea):Void
	{
		memory.access = this;
		
		_memory = memory;
		_offset = memory.b + memory.offset;
		_size = Std.int(memory.size / (getBitSize() >> 3));
	}
	
	inline public function offset():Int
	{
		return _offset;
	}
	
	public function size():Int
	{
		return _size;
	}
	
	public function clear():Void
	{
		var j:Int = _offset;
		for (i in 0..._memory.size)
			Memory.setByte(j + i, 0);
	}
	
	public function toString():String
	{
		return "{MemoryAccess, offset: " + _offset + ", size: " + _size + "}";
	}
	
	private function getBitSize():Int
	{
		return -1;
	}
}