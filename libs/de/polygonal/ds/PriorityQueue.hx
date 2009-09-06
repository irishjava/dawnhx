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

import de.polygonal.ds.Prioritizable;
import de.polygonal.ds.Set;
import flash.utils.Dictionary;
import flash.Vector;

/**
 * A heap-based priority queue.
 */
class PriorityQueue<T> implements haxe.rtti.Generic
{
	private var _heap:Vector<Prioritizable<T>>;
	
	private var _maxSize:Int;
	private var _size:Int;
	private var _inverse:Bool;
	
	#if debug
	private var _set:Dictionary;
	#end
	
	/**
	 * Create a new fixed-size priority queue.
	 * @param size The maximum size.
	 * @param inverse Reverse the priority (lower number equals higher priority).
	 */
	public function new(size:Int, ?inverse:Bool = false)
	{
		_maxSize = size;
		_inverse = inverse;
		_heap = new Vector<Prioritizable<T>>(_maxSize + 1, true);
		_size = 0;
		
		#if debug
		_set = new Dictionary(true);
		#end
	}
	
	inline public function front():Prioritizable<T>
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
	
	inline public function enqueue(val:Prioritizable<T>):Void
	{
		#if debug
		if (_size + 1 > _maxSize)
			throw "queue is full";
		if (_set[untyped val] != null)
			throw "value already exists";
		_set[untyped val] = val;
		#end
		
		_size++;
		_heap[_size] = val;
		val.id = _size;
		walkUp(_size);
	}
	
	inline public function dequeue():Prioritizable<T>
	{
		#if debug
		if (_size == 0) throw "queue is empty";
		untyped __delete__(_set, _heap[1]);
		#end
		
		var val:Prioritizable<T> = _heap[1];
		val.id = -1;
		_heap[1] = _heap[_size];
		walkDown(1);
		_size--;
		return val;
	}
	
	inline public function reprioritize(val:Prioritizable<T>, newPriority:Int):Void
	{
		#if debug
		if (_size == 0) throw "queue is empty";
		if (_set[untyped val] == null)
			throw "value does not exist";
		#end
		
		var oldPriority:Int = val.priority;
		if (oldPriority != newPriority)
		{
			val.priority = newPriority;
			var pos:Int = val.id;
			
			if (_inverse)
				newPriority < oldPriority ? walkUp(pos) : walkDown(pos);
			else
				newPriority > oldPriority ? walkUp(pos) : walkDown(pos);
		}
	}
	
	inline public function remove(val:Prioritizable<T>):Void
	{
		#if debug
		if (_size == 0) throw "queue is empty";
		if (_set[untyped val] == null)
			throw "value does not exists";
		untyped __delete__(_set, val);
		#end
		
		var pos:Int = val.id;
		var val:Prioritizable<T> = _heap[pos];
		val.id = -1;
		
		_heap[pos] = _heap[_size];
		walkDown(pos);
		_size--;
	}
	
	inline public function dispose():Void
	{
		_heap[_size + 1] = null;
	}
	
	public function toString():String
	{
		#if debug
		var tmp:PriorityQueue<T> = cast clone();
		var s:String = "\nPriorityQueue\n{\n";
		
		var i:Int = 0;
		while (tmp.size() > 0)
		{
			var val:Prioritizable<T> = tmp.dequeue();
			s += "\t#" + i++ + "\tp" + val.priority + "\t -> " + val + "\n";
		}
		s += "}";
		return s;
		#else
		return "{Heap, size: " + size() + "}";
		#end
	}
	
	inline private function walkUp(index:Int):Void
	{
		var parent:Int = index >> 1;
		var parentVal:Prioritizable<T>;
		var tmp:Prioritizable<T> = _heap[index];
		var p:Int = tmp.priority;
		
		if (_inverse)
		{
			while (parent > 0)
			{
				parentVal = _heap[parent];
				if (p - parentVal.priority < 0)
				{
					_heap[index] = parentVal;
					parentVal.id = index;
					
					index = parent;
					parent >>= 1;
				}
				else break;
			}
		}
		else
		{
			while (parent > 0)
			{
				parentVal = _heap[parent];
				if (p - parentVal.priority > 0)
				{
					_heap[index] = parentVal;
					parentVal.id = index;
					
					index = parent;
					parent >>= 1;
				}
				else break;
			}
		}
		
		_heap[index] = tmp;
		tmp.id = index;
	}
	
	inline private function walkDown(index:Int):Void
	{
		var child:Int = index << 1;
		var childVal:Prioritizable<T>;
		
		var tmp:Prioritizable<T> = _heap[index];
		var p:Int = tmp.priority;
		
		if (_inverse)
		{
			while (child < _size)
			{
				if (child < _size - 1)
					if (_heap[child].priority - _heap[child + 1].priority > 0)
						child++;
				
				childVal = _heap[child];
				if (p - childVal.priority > 0)
				{
					_heap[index] = childVal;
					childVal.id = index;
					tmp.id = child;
					index = child;
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
					if (_heap[child].priority - _heap[child + 1].priority < 0)
						child++;
				
				childVal = _heap[child];
				if (p - childVal.priority < 0)
				{
					_heap[index] = childVal;
					childVal.id = index;
					tmp.id = child;
					index = child;
					child <<= 1;
				}
				else break;
			}
		}
		
		_heap[index] = tmp;
		tmp.id = index;
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:Prioritizable<T>):Bool
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
		_heap = new Vector<Prioritizable<T>>(_maxSize + 1, true);
		_size = 0;
	}
	
	public function iterator():Iterator<T>
	{
		return new PriorityQueueIterator<T>(_heap, _size + 1);
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
			a[i - 1] = _heap[i].val;
		return a;
	}
	
	public function toVector():Vector<T>
	{
		var v:Vector<T> = new Vector<T>();
		for (i in 1..._size + 1)
			v[i - 1] = _heap[i].val;
		return v;
	}
	
	public function shuffle():Void
	{
		throw "unsupported operation";
	}
	
	public function clone():Collection<Prioritizable<T>>
	{
		var copy:PriorityQueue<T> = new PriorityQueue<T>(maxSize(), _inverse);
		for (i in 1..._size + 1)
			copy.enqueue(_heap[i].clone());
		return cast copy;
	}
}

class PriorityQueueIterator<T> implements haxe.rtti.Generic
{
	private var _v:Vector<Prioritizable<T>>;
	private var _i:Int;
	private var _s:Int;

	public function new(v:Vector<Prioritizable<T>>, s:Int)
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
		return _v[_i++].val;
	}
}