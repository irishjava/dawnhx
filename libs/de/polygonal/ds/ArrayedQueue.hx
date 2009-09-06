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

class ArrayedQueue<T> implements haxe.rtti.Generic
{
	private var _v:Vector<T>;

	private var _size:Int;
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
		
		_size = size;
		_mask = size - 1;
		
		_v = new Vector<T>(_size, true);
		_front = _count = 0;
	}

	inline public function maxSize():Int
	{
		return _size;
	}

	inline public function peek():T
	{
		#if debug
		if (_count == 0) throw "queue is empty";
		#end
		
		return _v[_front];
	}

	inline public function back():T
	{
		#if debug
		if (_count == 0) throw "queue is empty";
		#end
		
		return _v[(_count - 1 + _front) & _mask];
	}

	inline public function enqueue(val:T):Void
	{
		#if debug
		if (_size == _count) throw "queue is full";
		#end
		
		_v[(_count++ + _front) & _mask] = val;
	}

	inline public function dequeue():T
	{
		#if debug
		if (_count == 0) throw "queue is empty";
		#end
		
		var val:T = _v[_front++];
		if (_front == _size) _front = 0;
		_count--;
		return val;
	}

	inline public function dispose(nullifier:Null<T>):Void
	{
		#if debug
		if (_count == 0) throw "queue is empty";
		#end
		
		if (_front == 0)
			_v[_size - 1] = nullifier
		else
			_v[_front - 1] = nullifier;
	}

	inline public function getAt(i:Int):T
	{
		#if debug
		if (i >= _count) throw "index out of bounds";
		#end
		
		return _v[(i + _front) & _mask];
	}

	inline public function setAt(i:Int, val:T):Void
	{
		#if debug
		if (i >= _count) throw "index out of bounds";
		#end
		
		_v[(i + _front) & _mask] = val;
	}
	
	inline public function assign(val:T):Void
	{
		while (_count < _size)
			_v[(_count++ + _front) & _mask] = val;
	}
	
	inline public function factory(cl:Class<T>, args:Array<Dynamic> = null):Void
	{
		if (args == null) args = [];
		while (_count < _size)
			_v[(_count++ + _front) & _mask] = Type.createInstance(cl, args);
	}

	inline public function walk(process:T->Int->T):Void
	{
		for (i in 0..._size)
		{
			var j:Int = (i + _front) & _mask;
			_v[j] = process(_v[j], i);
		}
	}

	public function toString():String
	{
		#if debug
		var s:String = "\nArrayedQueue, size: " + _size + "\n{\n";
		
		s += "\t0\t-> " + getAt(0) + " (head)\n";
		for (i in 1..._count)
			s += '\t' + i + "\t-> " + getAt(i) + '\n';
		
		return s + '}';
		#else
		return "{ArrayedQueue, size: " + size() + " }";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:T):Bool
	{
		for (i in 0..._count)
		{
			if (_v[(i + _front) & _mask] == val)
				return true;
		}
		return false;
	}

	public function clear():Void
	{
		_front = _count = 0;
	}

	public function iterator():Iterator<T>
	{
		return new ArrayedQueueIterator<T>(_v, _front, _mask, _count);
	}

	public function size():Int
	{
		return _count;
	}

	public function isEmpty():Bool
	{
		return _count == 0;
	}

	public function toArray():Array<T>
	{
		var a:Array<T> = new Array<T>();
		for (i in 0..._count)
			a[i] = _v[(i + _front) & _mask];
		return a;
	}
	
	public function toVector():Vector<T>
	{
		var v:Vector<T> = new Vector<T>(_count, true);
		for (i in 0..._count)
			v[i] = _v[(i + _front) & _mask];
		return v;
	}
	
	public function shuffle():Void
	{
		var t:T;
		var i:Int;
		var s:Int = _count;
		while (s > 1)
		{
			s--;
			i = (Std.int(Math.random() * s) + _front) & _mask;
			t     = _v[s];
			_v[s] = _v[i];
			_v[i] = t;
		}
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		var copy:ArrayedQueue<T> = new ArrayedQueue<T>(_size);
		if (copier == null)
		{
			for (i in 0...size())
				copy.enqueue(getAt(i));
		}
		else
		{
			for (i in 0...size())
				copy.enqueue(copier(getAt(i)));
		}
		
		return cast copy;
	}
}

class ArrayedQueueIterator<T> implements haxe.rtti.Generic
{
	private var _v:Vector<T>;
	
	private var _front:Int;
	private var _mask:Int;
	private var _size:Int;
	
	private var _i:Int;
	
	public function new(v:Vector<T>, front:Int, mask:Int, size:Int)
	{
		_v = v;
		_front = front;
		_mask = mask;
		_size = size;
	}

	public function hasNext():Bool
	{
		return _i < _size;
	}

	public function next():T
	{
		return _v[(_i++ + _front) & _mask];
	}
}