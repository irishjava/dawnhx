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

import flash.Vector;

class Heap<T> implements haxe.rtti.Generic
{
	private var _heap:Vector<T>;
	private var _maxSize:Int;
	private var _size:Int;
	private var _compare:T->T->Int;
	
	public function new(size:Int, ?compare:T->T->Int = null)
	{
		_maxSize = size;
		_compare = compare;
		_heap = new Vector<T>(_maxSize + 1, true);
		_size = 0;
	}
	
	inline public function front():T
	{
		#if debug
		if (size() == 0)
			throw "queue is empty";
		#end
		
		return _heap[1];
	}
	
	inline public function maxSize():Int
	{
		return _maxSize;
	}
	
	inline public function enqueue(val:T):Void
	{
		#if debug
		if (_size + 1 > _maxSize)
			throw "heap is full";
		#end
		
		_heap[++_size] = val;
		
		var i:Int = _size;
		var parent:Int = i >> 1;
		var t0:T = _heap[i];
		
		if (_compare != null)
		{
			while (parent > 0)
			{
				var t1:T = _heap[parent];
				if (_compare(t0, t1) > 0)
				{
					_heap[i] = t1;
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
				var t1:T = _heap[parent];
				if (untyped t0 - t1 > 0)
				{
					_heap[i] = t1;
					i = parent;
					parent >>= 1;
				}
				else break;
			}
		}
		
		_heap[i] = t0;
	}
	
	inline public function dequeue():Null<T>
	{
		#if debug
		if (_size == 0) throw "heap is empty";
		#end
		
		var t0:T = _heap[1];
		_heap[1] = _heap[_size];
		
		var i:Int = 1;
		var child:Int = i << 1;
		var t1:T = _heap[i];
		
		if (_compare != null)
		{
			while (child < _size)
			{
				if (child < _size - 1)
				{
					if (_compare(_heap[child], _heap[child + 1]) < 0)
						child++;
				}
				var t2:T = _heap[child];
				if (_compare(t1, t2) < 0)
				{
					_heap[i] = t2;
					i = child;
					child <<= 1;
				}
				else break;
			}
		}
		else
		{
			while (child < _size)
			{
				if (child < _size - 1)
				{
					if (untyped _heap[child] - _heap[child + 1] < 0)
						child++;
				}
				var t2:T = _heap[child];
				if (untyped t1 - t2 < 0)
				{
					_heap[i] = t2;
					i = child;
					child <<= 1;
				}
				else break;
			}
		}
		
		_heap[i] = t1;
		
		_size--;
		return t0;
	}
	
	inline public function dispose(nullifier:Null<T>):Void
	{
		_heap[_size + 1] = nullifier;
	}
	
	public function toString():String
	{
		#if debug
		var tmp:Heap<T> = cast clone(null);
		var s:String = "\nHeap\n{\n";
		
		var i:Int = 0;
		while (tmp.size() > 0)
			s += "\t" + i++ + "\t -> " + tmp.dequeue() + "\n";
		s += "}";
		return s;
		#else
		return "{Heap, size: " + size() + "}";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:T):Bool
	{
		for (i in 1..._size + 1)
		{
			if (_heap[i] == val)
				return true;
		}
		return false;
	}
	
	public function clear():Void
	{
		_heap = new Vector<T>(_maxSize + 1, true);
		_size = 0;
	}
	
	public function iterator():Iterator<T>
	{
		return new HeapIterator<T>(_heap, _size + 1);
	}
	
	public function size():Int
	{
		return _size;
	}
	
	public function isEmpty():Bool
	{
		return _size == 0;
	}
	
	public function toArray():Array<T>
	{
		var a:Array<T> = new Array<T>();
		for (i in 1..._size + 1)
			a[i - 1] = _heap[i];
		return a;
	}
	
	public function toVector():Vector<T>
	{
		return _heap.slice(1, _size + 1);
	}
	
	public function shuffle():Void
	{
		throw "unsupported operation";
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		var copy:Heap<T> = new Heap<T>(maxSize(), _compare);
		if (copier == null)
		{
			for (i in this)
				copy.enqueue(i);
		}
		else
		{
			for (i in this)
				copy.enqueue(copier(i));
		}
		return cast copy;
	}
}

class HeapIterator<T> implements haxe.rtti.Generic
{
	private var _v:Vector<T>;
	private var _i:Int;
	private var _s:Int;

	public function new(v:Vector<T>, s:Int)
	{
		_v = v;
		_i = 1;
		_s = s;
	}

	public function hasNext():Bool
	{
		return _i < _s;
	}

	public function next():T
	{
		return _v[_i++];
	}
}