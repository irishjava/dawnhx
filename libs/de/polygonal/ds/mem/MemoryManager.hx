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

import flash.utils.ByteArray;
import flash.Memory;

class MemoryManager
{
	static var _instance:MemoryManager = null;
	static var _memoryBytes:Int = 0;
	
	public static function initialize(memoryKiB:Int, ?rawMemoryKiB:Int = 1):Void
	{
		if (_instance == null)
			_instance = new MemoryManager(memoryKiB, rawMemoryKiB);
	}
	
	var _intervalList:MemoryArea;
	
	function new(memoryKiB:Int, ?rawMemoryKiB:Int = 1)
	{
		_memoryBytes = memoryKiB << 10;
		
		var rawMemoryOffsetBytes:Int = rawMemoryKiB << 10;
		
		_intervalList = new MemoryArea(this, rawMemoryOffsetBytes);
		_intervalList.expandRight(_memoryBytes);
		
		var bytes:ByteArray = new ByteArray();
		bytes.length = rawMemoryOffsetBytes + (_memoryBytes << 1);
		Memory.select(bytes);
		
		#if verbose
		trace("allocated " + Math.round(bytes.length / 1024 / 1024 / .01) * .01 + " MiB in total (" + memoryKiB + " KiB available)");
		#end
	}
	
	public static function getTotalBytes():Int
	{
		#if debug
		if (_instance == null) throw "call allocate first";
		#end
		
		return _memoryBytes;
	}
	
	public static function getUsedBytes():Int
	{
		#if debug
		if (_instance == null) throw "call allocate first";
		#end
		
		var bytes:Int = 0;
		var m:MemoryArea = _instance._intervalList;
		while (m != null)
		{
			if (m.isEmpty == false)
				bytes += m.size;
			m = m.next;
		}
		return bytes;
	}
	
	public static function getFreeBytes():Int
	{
		#if debug
		if (_instance == null) throw "call allocate first";
		#end
		
		return getTotalBytes() - getUsedBytes();
	}
	
	public static function assignMemory(bytes:Int, memoryAccess:MemoryAccess):Void
	{
		#if debug
		if (_instance == null) throw "call allocate first";
		if (bytes > _memoryBytes)
			throw "requested size exceeds maximum size";
		#end
		
		var memory:MemoryArea = _instance.allocate(bytes);
		memoryAccess.setMemory(memory);
	}
	
	public static function getBitMemory(size:Int):BitMemory
	{
		var intSize:Int = size >> 5;
		if ((size & 31) > 0) intSize++;
		
		#if debug
		if (_instance == null) throw "call allocate first";
		if ((intSize << 2) > _memoryBytes)
			throw "requested size exceeds maximum size";
		#end
		
		var memory:MemoryArea = _instance.allocate(intSize << 2);
		var memoryAccess:BitMemory = new BitMemory(size);
		memoryAccess.setMemory(memory);
		return memoryAccess;
	}
	
	public static function getByteMemory(size:Int):ByteMemory
	{
		#if debug
		if (_instance == null) throw "call allocate first";
		if (size > _memoryBytes)
			throw "requested size exceeds maximum size";
		#end
		
		var memory:MemoryArea = _instance.allocate(size);
		var memoryAccess:ByteMemory = new ByteMemory();
		memoryAccess.setMemory(memory);
		return memoryAccess;
	}
	
	public static function getIntMemory(size:Int):IntMemory
	{
		#if debug
		if (_instance == null) throw "call allocate first";
		if ((size << 2) > _memoryBytes)
			throw "requested size exceeds maximum size";
		#end
		
		var memory:MemoryArea = _instance.allocate(size << 2);
		var memoryAccess:IntMemory = new IntMemory();
		memoryAccess.setMemory(memory);
		return memoryAccess;
	}
	
	public static function getFloatMemory(size:Int):FloatMemory
	{
		#if debug
		if (_instance == null) throw "call allocate first";
		if ((size << 2) > _memoryBytes)
			throw "requested size exceeds maximum size";
		#end
		
		var memory:MemoryArea = _instance.allocate(size << 2);
		var memoryAccess:FloatMemory = new FloatMemory();
		memoryAccess.setMemory(memory);
		return memoryAccess;
	}
	
	public static function getDoubleMemory(size:Int):DoubleMemory
	{
		#if debug
		if (_instance == null) throw "call allocate first";
		if ((size << 3) > _memoryBytes || (size << 3) > _memoryBytes)
			throw "requested size exceeds maximum size";
		#end
		
		var memory:MemoryArea = _instance.allocate(size << 3);
		var memoryAccess:DoubleMemory = new DoubleMemory();
		memoryAccess.setMemory(memory);
		return memoryAccess;
	}
	
	public function purge(memory:MemoryArea):Void
	{
		deallocate(memory);
	}
	
	#if debug
	public static function forceDefragment():Void
	{
		_instance.defragment();
	}
	
	public static function draw(g:flash.display.Graphics, r:flash.geom.Rectangle):Void
	{
		var pTotal:Float = 0;
		var i:MemoryArea = _instance._intervalList;
		while (i != null)
		{
			var p:Float = i.size / _memoryBytes;
			
			g.lineStyle(0, 0xffffff, 1);
			g.beginFill(i.isEmpty ? 0x0090da : 0xf0149a, 1);
			g.drawRect(r.x + pTotal * r.width, r.y, r.width * p, r.height);
			g.endFill();
			
			pTotal += p;
			i = i.next;
		}
	}
	
	public static function print():String
	{
		var s:String = "{MemoryManager, " + getFreeBytes() + " bytes available}";
		
		#if debug
		s += "\n";
		var i:MemoryArea = _instance._intervalList;
		var j:Int = 0;
		while (i != null)
		{
			s += j + " -> " + i + "\n";
			i = i.next;
		}
		#end
		
		return s;
	}
	#end
	
	function allocate(size:Int):MemoryArea
	{
		var area:MemoryArea = findEmptySpace(size);
		if (area == null)
		{
			defragment();
			
			area = findEmptySpace(size);
			if (area == null)
				throw "out of memory";
			return area;
		}
		
		return area;
	}
	
	function deallocate(memory:MemoryArea):Void
	{
		//try to merge adjacent empty intervals
		if (memory.next != null)
			if (memory.next.isEmpty)
				mergeRight(memory);
		
		if (memory.prev != null)
			if (memory.prev.isEmpty)
				mergeLeft(memory);
	}
	
	function defragment():Void
	{
		var i0:MemoryArea;
		var i1:MemoryArea = _intervalList.next;
		
		//empty list
		if (i1 == null) return;
		
		var offset:Int = i1.offset;
		
		//find tail
		while (i1.next != null) i1 = i1.next;
		
		//iterate from tail to head
		while (i1.prev != null)
		{
			i0 = i1.prev;
			if (i1.isEmpty)
			{
				if (i0.isEmpty == false)
				{
					//move data
					var t:Int = i0.size - i1.size;
					if (t == 0)
					{
						//exact fit
						memmove(i1.b, i0.b, i0.size, offset);
						wipe(i0.b, i0.size, offset);
						
						i0.access.setMemory(i1);
					}
					else
					if (t < 0)
					{
						//fits
						memmove(i1.e - i0.size + 1, i0.b, i0.size, offset);
						wipe(i0.b, i0.size, offset);
						
						i0.expandRight(-t);
						i1.shrinkRight(-t);
						
						i0.access.setMemory(i1);
					}
					else
					if (t > 0)
					{
						//does not fit
						memmove(i0.b + i1.size, i0.b, i0.size, offset);
						wipe(i0.b, i1.size, offset);
						
						i1.expandLeft(t);
						i0.shrinkLeft(t);
						
						i0.access.setMemory(i1);
					}
					
					i1.isEmpty = false;
					i0.isEmpty = true;
				}
				else
				{
					//merge empty intervals
					mergeRight(i0);
					i1 = i0.next;
				}
			}
			
			i1 = i1.prev;
		}
	}
	
	function findEmptySpace(size:Int):MemoryArea
	{
		var m:MemoryArea = _intervalList;
		var j:Int = 0;
		
		while (m != null)
		{
			if (m.isEmpty)
			{
				//found interval
				if (m.size >= size)
				{
					//exact match
					if (m.size == size)
					{
						m.isEmpty = false;
						return m;
					}
					else
					{
						//split in half
						var m1:MemoryArea = m.copy();
						m1.isEmpty = false;
						
						m.shrinkLeft(size);
						m1.shrinkRight(m.size);
						
						m1.prev = m;
						m1.next = m.next;
						
						if (m.next != null)
							m.next.prev = m1;
						
						m.next = m1;
						
						return m1;
					}
				}
			}
			
			m = m.next;
		}
		
		return null;
	}
	
	function mergeLeft(m:MemoryArea):Void
	{
		//merge m and m.prev
		var m0:MemoryArea = m.prev;
		
		m.b = m0.b;
		m.size = m.e - m.b + 1;
		
		m.prev = m0.prev;
		if (m.prev != null) m.prev.next = m;
		
		m0.prev = null;
		m0.next = null;
		
		//update head
		if (m.prev == null)
			_intervalList = m;
	}
	
	function mergeRight(m:MemoryArea):Void
	{
		//merge m and m.next
		var m1:MemoryArea = m.next;
		
		m.e = m1.e;
		m.size = m.e - m.b + 1;
		
		m.next = m1.next;
		if (m.next != null) m.next.prev = m;
		
		m1.prev = null;
		m1.next = null;
	}
	
	function memmove(destination:Int, source:Int, size:Int, offset:Int):Void
	{
		#if verbose
		trace("move " + (source) + "..." + (source + (size - 1)) + " to " + ((destination ) + "..." + (destination + (size - 1))));
		#end
		
		if (destination + size < source)
		{
			for (i in offset...size + offset) Memory.setByte(destination + i, Memory.getByte(source + i));
		}
		else
		if (destination > source + size)
		{
			for (i in offset...size + offset) Memory.setByte(destination + i, Memory.getByte(source + i));
		}
		else
		{
			for (i in offset...size + offset) Memory.setByte(_memoryBytes + i, Memory.getByte(source + i));
			for (i in offset...size + offset) Memory.setByte(destination + i, Memory.getByte(_memoryBytes + i));
		}
	}
	
	function wipe(destination:Int, size:Int, offset:Int):Void
	{
		#if verbose
		trace("wipe from " + (destination ) + " to " + (destination + (size - 1)));
		#end
		
		for (i in offset...size + offset) Memory.setByte(destination + i, 0);
	}
}