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

class DoubleMemoryAccessor extends MemoryAccess
{
	public function new(sizeDouble:Int)
	{
		super();
		MemoryManager.assignMemory(sizeDouble << 3, this);
	}
	
	inline public function purge():Void
	{
		clear();
		_memory.purge();
		_memory = null;
	}
	
	inline function memget(index:Int):Float
	{
		return Memory.getDouble(_offset + (index << 3));
	}
	
	inline function memset(index:Int, val:Float):Void
	{
		Memory.setDouble(_offset + (index << 3), val);
	}
	
	inline function memswp(i:Int, j:Int):Void
	{
		var i:Int = _offset + (i << 3);
		var j:Int = _offset + (j << 3);
		var t:Float = Memory.getDouble(i);
		Memory.setDouble(i, Memory.getDouble(j));
		Memory.setDouble(j, t);
	}
	
	override private function getBitSize():Int
	{
		return 64;
	}
}