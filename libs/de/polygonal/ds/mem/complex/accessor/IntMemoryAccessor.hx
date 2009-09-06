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

package de.polygonal.ds.mem.complex.accessor;

import de.polygonal.ds.mem.MemoryAccess;
import de.polygonal.ds.mem.MemoryManager;
import flash.Memory;

class IntMemoryAccessor extends MemoryAccess
{
	public function new(sizeInt:Int)
	{
		super();
		MemoryManager.assignMemory(sizeInt << 2, this);
	}
	
	inline public function purge():Void
	{
		clear();
		_memory.purge();
		_memory = null;
	}
	
	inline function memget(index:Int):Int
	{
		return Memory.getI32(_offset + (index << 2));
	}
	
	inline function memset(index:Int, val:Int):Void
	{
		Memory.setI32(_offset + (index << 2), val);
	}
	
	inline function memswp(i:Int, j:Int):Void
	{
		var i:Int = _offset + (i << 2);
		var j:Int = _offset + (j << 2);
		var t:Int = Memory.getI32(i);
		Memory.setI32(i, Memory.getI32(j));
		Memory.setI32(j, t);
	}
	
	override private function getBitSize():Int
	{
		return 32;
	}
}