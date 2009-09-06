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

package de.polygonal.ds.mem.complex;

import de.polygonal.ds.Collection;
import de.polygonal.ds.mem.complex.accessor.IntMemoryAccessor;
import de.polygonal.ds.mem.MemoryAccess;
import de.polygonal.ds.mem.MemoryManager;
import flash.Memory;
import flash.Vector;

class MemQueueInteger extends IntMemoryAccessor
{
	private var _mask:Int;
	private var _count:Int;
	private var _front:Int;
	
	public function new(size:Int)
	{
		#if debug
		var isPow2:Bool = size > 0 && (size & (size - 1)) == 0;
		if (isPow2 == false)
			throw "size is not a power of 2";
		#end
		
		super(size);
		
		_mask = size - 1;
		_front = _count = 0;
	}

	inline public function maxSize():Int
	{
		return _size;
	}

	inline public function peek():Int
	{
		#if debug
		if (_count == 0) throw "queue is empty";
		#end
		
		return memget(_front);
	}

	inline public function back():Int
	{
		#if debug
		if (_count == 0) throw "queue is empty";
		#end
		
		return memget((_count - 1 + _front) & _mask);
	}

	inline public function enqueue(val:Int):Void
	{
		#if debug
		if (_size == _count) throw "queue is full";
		#end
		
		memset((_count++ + _front) & _mask, val);
	}

	inline public function dequeue():Int
	{
		#if debug
		if (_count == 0) throw "queue is empty";
		#end
		
		var val:Int = memget(_front++);
		if (_front == _size) _front = 0;
		_count--;
		return val;
	}

	inline public function getAt(i:Int):Int
	{
		#if debug
		if (i >= _count) throw "index out of bounds";
		#end
		
		return memget((i + _front) & _mask);
	}

	inline public function setAt(i:Int, val:Int):Void
	{
		#if debug
		if (i >= _count) throw "index out of bounds";
		#end
		
		memset((i + _front) & _mask, val);
	}

	inline public function walk(process:Int->Int->Int):Void
	{
		for (i in 0..._size)
		{
			var j:Int = (i + _front) & _mask;
			memset(j, process(memget(j), i));
		}
	}

	override public function toString():String
	{
		#if debug
		var s:String = "\nMemQueueInt, size: " + _size + "\n{\n";
		
		s += '\t' + 0 + "\t-> " + getAt(0) + " (head)\n";
		for (i in 1..._count)
			s += '\t' + i + "\t-> " + getAt(i) + '\n';
		
		return s + '}';
		#else
		return "{MemQueueInt, size: " + size() + " }";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:Int):Bool
	{
		for (i in 0..._count)
		{
			if (memget((i + _front) & _mask) == val)
				return true;
		}
		return false;
	}

	override public function clear():Void
	{
		super.clear();
		_front = _count = 0;
	}

	public function iterator():Iterator<Int>
	{
		return new MemQueueIntIterator<Int>(_offset, _front, _mask, _count);
	}

	override public function size():Int
	{
		return _count;
	}

	public function isEmpty():Bool
	{
		return _count == 0;
	}

	public function toArray():Array<Int>
	{
		var a:Array<Int> = new Array<Int>();
		for (i in 0..._count)
			a[i] = memget((i + _front) & _mask);
		return a;
	}
	
	public function toVector():Vector<Int>
	{
		var v:Vector<Int> = new Vector<Int>(_count, true);
		for (i in 0..._count)
			v[i] = memget((i + _front) & _mask);
		return v;
	}
	
	public function shuffle():Void
	{
		var s:Int = _count;
		while (s > 1)
		{
			s--;
			memswp((Std.int(Math.random() * s) + _front) & _mask, s);
		}
	}
	
	public function clone(copier:Int->Int):Collection<Int>
	{
		var copy:MemQueueInteger = new MemQueueInteger(_size);
		for (i in 0...size()) copy.enqueue(getAt(i));
		return cast copy;
	}
}

class MemQueueIntIterator<T>
{
	private var _offset:Int;
	private var _front:Int;
	private var _mask:Int;
	private var _size:Int;
	
	private var _i:Int;
	
	public function new(offset:Int, front:Int, mask:Int, size:Int)
	{
		_offset = offset;
		_front = front;
		_mask = mask;
		_size = size;
	}

	public function hasNext():Bool
	{
		return _i < _size;
	}

	public function next():Int
	{
		return Memory.getI32(_offset + (((_i++ + _front) & _mask) << 2));
	}
}