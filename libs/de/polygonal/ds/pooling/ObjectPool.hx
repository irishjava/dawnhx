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

package de.polygonal.ds.pooling;

import flash.Vector;

class ObjectPool<T> implements haxe.rtti.Generic
{
	private var _pool:Vector<ObjectPoolItem<T>>;
	private var _size:Int;
	private var _free:Int;
	private var _item:ObjectPoolItem<T>;
	
	private var _factory:Factory<T>;
	private var _factoryMethod:Void->T;
	
	#if debug
	private var _count:Int;
	#end

	public function new() {}

	public function deconstruct():Void
	{
		if (_pool != null)
		{
			for (i in 0..._pool.length)
			{
				_pool[i].obj = null;
				_pool[i] = null;
			}
			
			_item = null;
			_pool = null;
		}
	}
	
	inline public function get():Int
	{
		#if debug
		if (_count++ == _size || _free == -1)
			throw "pool is empty";
		#end
		
		_item = _pool[_free];
		_free = _item.next;
		
		return _item.id;
	}
	
	inline public function put(id:Int):Void
	{
		#if debug
		if (--_count < 0)
			throw "pool is full";
		#end
		
		var item:ObjectPoolItem<T> = _pool[id];
		item.next = _free;
		_free = item.id;
	}
	
	inline public function obj():T
	{
		return _item.obj;
	}
	
	inline public function see(id:Int):T
	{
		return _pool[id].obj;
	}
	
	inline public function size():Int
	{
		return _size;
	}
	
	public function allocate(size:Int, ?C:Class<T> = null):Void
	{
		deconstruct();
		
		_size = size;
		_pool = new Vector<ObjectPoolItem<T>>(size, true);
		
		if (C != null)
			_factory = new ClassFactory<T>(C);
		
		if (_factory != null)
		{
			for (i in 0...size - 1)
			{
				var item:ObjectPoolItem<T> = new ObjectPoolItem<T>();
				item.next = i + 1;
				item.id = i;
				item.obj = _factory.create();
				_pool[i] = item;
			}
			
			var item:ObjectPoolItem<T> = new ObjectPoolItem<T>();
			item.next = -1;
			item.id = size - 1;
			item.obj = _factory.create();
			_pool[size - 1] = item;
		}
		else
		{
			if (_factoryMethod != null)
			{
				for (i in 0...size - 1)
				{
					var item:ObjectPoolItem<T> = new ObjectPoolItem<T>();
					item.next = i + 1;
					item.id = i;
					item.obj = _factoryMethod();
					_pool[i] = item;
				}
				
				var item:ObjectPoolItem<T> = new ObjectPoolItem<T>();
				item.next = -1;
				item.id = size - 1;
				item.obj = _factoryMethod();
				_pool[size - 1] = item;
			}
			else
			{
				#if debug
				throw "no factory defined";
				#end
			}
		}
	}

	public function setFactory(factory:Factory<T>):Void
	{
		_factory = factory;
	}
	
	public function setFactoryMethod(factory:Void->T):Void
	{
		_factoryMethod = factory;
	}

	public function iterator():Iterator<T>
	{
		return new ObjectPoolIterator<T>(_pool);
	}
	
	public function toString():String
	{
		#if debug
		var s:String = "\nArrayedObjectPool, size: " + size() + "\n{\n";
		var i:Int = 0;
		for (i in 0..._size)
		{
			s += "\n\t" + i + "\t -> " + _pool[i] + "\n";
		}
		return s + "}";
		#else
		return "{ObjectPool, size: " + size() + "}";
		#end
	}
}

class ObjectPoolItem<T> implements haxe.rtti.Generic
{
	public var obj:T;
	
	public var next:Int;
	public var id:Int;

	public function new() {}

	public function toString()
	{
		return "{ObjectPoolItem, id: " + id + ", next: " + next + ", obj: " + obj + "}";
	}
}

class ObjectPoolIterator<T> implements haxe.rtti.Generic
{
	private var _v:Vector<ObjectPoolItem<T>>;
	private var _s:Int;
	private var _i:Int;
	
	public function new(v:Vector<ObjectPoolItem<T>>)
	{
		_v = v;
		_s = v.length;
		_i = 0;
	}
	
	public function next():T
	{
		return _v[_i++].obj;
	}
	
	public function hasNext():Bool
	{
		return _i < _s;
	}
}