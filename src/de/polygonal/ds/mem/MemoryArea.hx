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

class MemoryArea
{
	public var next:MemoryArea;
	public var prev:MemoryArea;

	public var b:Int;
	public var e:Int;
	
	public var isEmpty:Bool;
	public var size:Int;
	
	public var manager:MemoryManager;
	public var access:MemoryAccess;
	public var offset:Int;
	
	public function new(manager:MemoryManager, offset:Int)
	{
		this.manager = manager;
		this.offset = offset;
		b = e = size = 0;
		isEmpty = true;
	}
	
	public function purge():Void
	{
		isEmpty = true;
		manager.purge(this);
	}
	
	public function expandLeft(s:Int):Void
	{
		size += s;
		b = e - size + 1;
	}
	
	public function shrinkLeft(s:Int):Void
	{
		size -= s;
		e = b + size - 1;
	}
	
	public function expandRight(s:Int):Void
	{
		size += s;
		e = b + size - 1;
	}
	
	public function shrinkRight(s:Int):Void
	{
		size -= s;
		b = e - size + 1;
	}
	
	public function copy():MemoryArea
	{
		var copy:MemoryArea = new MemoryArea(manager, offset);
		copy.b = b;
		copy.e = e;
		copy.isEmpty = isEmpty;
		copy.size = size;
		return copy;
	}
	
	public function toString():String
	{
		#if debug
		return "{MemoryArea, range: " + b + "->" + e + ", len: " + size + " ,isEmpty: " + isEmpty + "]";
		#else
		return "{MemoryArea, bytes: " + size + "}";
		#end
	}
}