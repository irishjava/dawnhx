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

import de.polygonal.ds.mem.complex.accessor.IntMemoryAccessor;
import de.polygonal.ds.Collection;
import flash.Vector;
import flash.Memory;

class MemHeapInt extends IntMemoryAccessor
{
	private var _maxSize:Int;
	private var _count:Int;
	private var _compare:Int->Int->Int;
	
	public function new(size:Int, ?compare:Int->Int->Int = null)
	{
		_maxSize = size;
		_compare = compare;
		super(_maxSize + 1);
		_count = 0;
	}
	
	inline public function front():Int
	{
		#if debug
		if (size() == 0)
			throw "queue is empty";
		#end
		
		return memget(1);
	}
	
	inline public function maxSize():Int
	{
		return _maxSize;
	}
	
	inline public function enqueue(val:Int):Void
	{
		#if debug
		if (_count + 1 > _maxSize)
			throw "heap is full";
		#end
		
		memset(++_count, val);
		
		var i:Int = _count;
		var parent:Int = i >> 1;
		var t0:Int = memget(i);
		
		if (_compare != null)
		{
			while (parent > 0)
			{
				var t1:Int = memget(parent);
				if (_compare(t0, t1) > 0)
				{
					memset(i, t1);
					i = parent;
					parent >>= 1;
				}
				else break;
			}
		}
		else
		{
			while (parent > 0)
			{
				var t1:Int = memget(parent);
				if (untyped t0 - t1 > 0)
				{
					memset(i, t1);
					i = parent;
					parent >>= 1;
				}
				else break;
			}
		}
		
		memset(i, t0);
	}
	
	inline public function dequeue():Int
	{
		#if debug
		if (_count == 0) throw "heap is empty";
		#end
		
		var t0:Int = memget(1);
		memset(1, memget(_count));
		
		var i:Int = 1;
		var child:Int = i << 1;
		var t1:Int = memget(i);
		
		if (_compare != null)
		{
			while (child < _count)
			{
				if (child < _count - 1)
				{
					if (_compare(memget(child), memget(child + 1)) < 0)
						child++;
				}
				var t2:Int = memget(child);
				if (_compare(t1, t2) < 0)
				{
					memset(i, t2);
					i = child;
					child <<= 1;
				}
				else break;
			}
		}
		else
		{
			while (child < _count)
			{
				if (child < _count - 1)
				{
					if (untyped memget(child) - memget(child + 1) < 0)
						child++;
				}
				var t2:Int = memget(child);
				if (untyped t1 - t2 < 0)
				{
					memset(i, t2);
					i = child;
					child <<= 1;
				}
				else break;
			}
		}
		
		memset(i, t1);
		
		_count--;
		return t0;
	}
	
	override public function toString():String
	{
		#if debug
		var tmp:MemHeapInt = cast clone(null);
		var s:String = "\nMemHeapInt\n{\n";
		
		var i:Int = 0;
		while (tmp.size() > 0)
			s += "\t" + i++ + "\t -> " + tmp.dequeue() + "\n";
		s += "}";
		return s;
		#else
		return "{MemHeapInt, size: " + size() + "}";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:Int):Bool
	{
		for (i in 1..._count + 1)
		{
			if (memget(i) == val)
				return true;
		}
		return false;
	}
	
	override public function clear():Void
	{
		super.clear();
		_count = 0;
	}
	
	public function iterator():Iterator<Int>
	{
		return new MemHeapIntIterator<Int>(_offset, _count + 1);
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
		for (i in 1..._count + 1)
			a[i - 1] = memget(i);
		return a;
	}
	
	public function toVector():Vector<Int>
	{
		var v:Vector<Int> = new Vector<Int>();
		for (i in 1..._count + 1)
			v[i - 1] = memget(i);
		return v;
	}
	
	public function shuffle():Void
	{
		throw "unsupported operation";
	}
	
	public function clone(copier:Int->Int):Collection<Int>
	{
		var copy:MemHeapInt = new MemHeapInt(maxSize(), _compare);
		for (i in this) copy.enqueue(i);
		return cast copy;
	}
}

class MemHeapIntIterator<T>
{
	private var _offset:Int;
	private var _i:Int;
	private var _s:Int;

	public function new(offset:Int, s:Int)
	{
		_offset = offset;
		_i = 1;
		_s = s;
	}

	public function hasNext():Bool
	{
		return _i < _s;
	}

	public function next():T
	{
		return untyped Memory.getI32(_offset + ((_i++) << 2));
	}
}