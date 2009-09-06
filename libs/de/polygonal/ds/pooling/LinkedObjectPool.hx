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

class LinkedObjectPool<T> implements haxe.rtti.Generic
{
	private var _initSize:Int;
	private var _currSize:Int;
	private var _usageCount:Int;

	private var _head:ObjNode<T>;
	private var _tail:ObjNode<T>;
	
	private var _emptyNode:ObjNode<T>;
	private var _allocNode:ObjNode<T>;
	
	private var _autoResize:Bool;

	private var _factory:Factory<T>;
	
	public function new(?autoResize:Bool = false)
	{
		_autoResize = autoResize;
	}
	
	public function deconstruct():Void
	{
		var node:ObjNode<T> = _head;
		var t:ObjNode<T>;
		while (node != null)
		{
			t = node.next;
			node.next = null;
			node.val = null;
			node = t;
		}

		_head = _tail = _emptyNode = _allocNode = null;
	}

	inline public function getSize():Int
	{
		return _currSize;
	}

	inline public function getUsageCount():Int
	{
		return _usageCount;
	}

	inline public function getWasteCount():Int
	{
		return _currSize - _usageCount;
	}

	inline public function get():T
	{
		if (_usageCount == _currSize)
		{
			if (_autoResize)
			{
				grow();
				return getInternal();
			}
			else
				throw "object pool exhausted";
		}
		else
		{
			return getInternal();
		}
	}

	inline public function put(o:T):Void
	{
		#if debug
		if (_usageCount == 0) throw "object pool is full";
		#end
		
		_usageCount--;
		_emptyNode.val = o;
		_emptyNode = _emptyNode.next;
	}

	public function allocate(initialSize:Int, ?C:Class<T> = null):Void
	{
		deconstruct();
		
		if (C != null)
			_factory = new ClassFactory<T>(C);
		else
			if (_factory == null)
				throw "no factory or class to instantiate";
		
		_initSize = _currSize = initialSize;

		_head = _tail = new ObjNode<T>();
		_head.val = _factory.create();
		
		var n:ObjNode<T>;
		for (i in 1..._initSize)
		{
			n = new ObjNode<T>();
			n.val = _factory.create();
			n.next = _head;
			_head = n;
		}
		
		_emptyNode = _allocNode = _head;
		_tail.next = _head;
	}

	public function purge():Void
	{
		if (_usageCount == 0)
		{
			if (_currSize == _initSize)
				return;

			if (_currSize > _initSize)
			{
				var i:Int = 0;
				var node:ObjNode<T> = _head;
				while (++i < _initSize)
					node = node.next;

				_tail = node;
				_allocNode = _emptyNode = _head;

				_currSize = _initSize;
				return;
			}
		}
		else
		{
			var i:Int = 0;
			var a:Array<ObjNode<T>> = new Array<ObjNode<T>>();
			var node:ObjNode<T> =_head;
			while (node != null)
			{
				if (node.val == null) a[i++] = node;
				if (node == _tail) break;
				node = node.next;
			}

			_currSize = a.length;
			_usageCount = _currSize;

			_head = _tail = a[0];
			for (i in 1..._currSize)
			{
				node = a[i];
				node.next = _head;
				_head = node;
			}

			_emptyNode = _allocNode = _head;
			_tail.next = _head;

			if (_usageCount < _initSize)
			{
				_currSize = _initSize;

				var n:ObjNode<T> = _tail;
				var t:ObjNode<T> = _tail;
				var k:Int = _initSize - _usageCount;
				for (i in 0...k)
				{
					node = new ObjNode<T>();
					node.val = _factory.create();

					t.next = node;
					t = node;
				}

				_tail = t;

				_tail.next = _emptyNode = _head;
				_allocNode = n.next;

			}
		}
	}
	
	public function setFactory(factory:Factory<T>):Void
	{
		_factory = factory;
	}
	
	public function toString():String
	{
		var s:String = "LinkedObjectPool (" + getUsageCount() + "/" + getSize() + " objects used)";
		
		#if debug
		var s:String = "\n" + s + "\n{";
		var node:ObjNode<T> = _head;
		var i:Int = 0;
		
		while (true)
		{
			s += "\n\t " + i++ + "\t -> " + node.val;
			node = node.next;
			if (node == _head) break;
		}
		return s + "\n}";
		#else
		return "{" + s + "}";
		#end
	}
	
	inline private function grow():Void
	{
		#if debug
		trace("resizing object pool from " + _currSize + " to " + (_currSize + _initSize));
		#end
		
		_currSize += _initSize;
		
		var n:ObjNode<T> = _tail;
		var t:ObjNode<T> = _tail;
		
		var node:ObjNode<T>;
		for (i in 0..._initSize)
		{
			node = new ObjNode<T>();
			node.val = _factory.create();
			t.next = node;
			t = node;
		}

		_tail = t;
		_tail.next = _emptyNode = _head;
		_allocNode = _tail;
		_allocNode = n.next;
	}
	
	inline private function getInternal():T
	{
		_usageCount++;
		var o:T = _allocNode.val;
		_allocNode.val = null;
		_allocNode = _allocNode.next;
		return o;
	}
}

class ObjNode<T> implements haxe.rtti.Generic
{
	public var next:ObjNode<T>;
	public var val:T;
	
	public function new() {}
}