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

import de.polygonal.ds.Collection;
import de.polygonal.ds.Compare;
import de.polygonal.ds.pooling.ObjectPool;
import flash.Lib;
import flash.Vector;

class FastDLL<T> implements haxe.rtti.Generic
{
	private var _head:FastDLLNode<T>;
	private var _tail:FastDLLNode<T>;
	
	private var _size:Int;
	
	private var _pool:ObjectPool<FastDLLNode<T>>;
	
	public function new(size:Int)
	{
		_head = _tail = null;
		_size = 0;
		
		_pool = new ObjectPool<FastDLLNode<T>>();
		_pool.setFactoryMethod(function () { return new FastDLLNode<T>(null); });
		_pool.allocate(size);
	}
	
	inline public function head():FastDLLNode<T>
	{
		return _head;
	}
	
	inline public function tail():FastDLLNode<T>
	{
		return _tail;
	}
	
	inline public function append(val:T):FastDLLNode<T>
	{
		var node:FastDLLNode<T> = getNode(val);
		if (valid(_tail))
			_tail.next = node;
		else
			_head = node;
		
		node.prev = _tail;
		_tail = node;
		
		_size++;
		return node;
	}
	
	inline public function prepend(val:T):FastDLLNode<T>
	{
		var node:FastDLLNode<T> = getNode(val);
		node.next = _head;
		if (valid(_head))
			_head.prev = node;
		else
			_tail = node;
		_head = node;
		
		_size++;
		return node;
	}
	
	inline public function insertAfter(node:FastDLLNode<T>, val:T):FastDLLNode<T>
	{
		var t:FastDLLNode<T> = getNode(val);
		node.insertAfter(t);
		if (node == _tail) _tail = t;
		_size++;
		return t;
	}
	
	inline public function insertBefore(node:FastDLLNode<T>, val:T):FastDLLNode<T>
	{
		var t:FastDLLNode<T> = getNode(val);
		node.insertBefore(t);
		if (node == _head) _head = t;
		_size++;
		return t;
	}
	
	inline public function remove(node:FastDLLNode<T>):Void
	{
		#if debug
		if (isEmpty())
			throw "list is empty";
		if (node.list != this)
			throw "node is not part of this list";
		#end
		
		putNode(node.id);
		
		if (node == _head) _head = _head.next;
		else
		if (node == _tail) _tail = _tail.prev;
		
		node.unlink();
		
		if (_head == null) _tail = null;
		
		_size--;
	}
	
	inline public function getNodeAt(i:Int):FastDLLNode<T>
	{
		#if debug
		if (i < 0 || i >= _size) throw "index out of bounds";
		#end
		
		var node:FastDLLNode<T> = _head;
		for (j in 0...i) node = node.next;
		return node;
	}
	
	inline public function removeHead():T
	{
		#if debug
		if (isEmpty()) throw "list is empty";
		#end
		
		var val:T = _head.val;
		_size--;
		
		putNode(_head.id);
		
		if (_head == _tail)
		{
			_head = _tail = null;
		}
		else
		{
			_head = _head.next;
			_head.prev = null;
		}
		
		return val;
	}
	
	inline public function removeTail():T
	{
		#if debug
		if (isEmpty()) throw "list is empty";
		#end
		
		putNode(_tail.id);
		
		var val:T = _tail.val;
		_size--;
		
		if (_head == _tail)
		{
			_head = _tail = null;
		}
		else
		{
			_tail = _tail.prev;
			_tail.next = null;
		}
		return val;
	}
	
	inline public function shiftUp():Void
	{
		#if debug
		if (size() <= 1)
			throw "list is too small";
		#end
		
		var t:FastDLLNode<T> = _head;
		if (_head.next == _tail)
		{
			_head = _tail;
			_head.prev = null;
			
			_tail = t;
			_tail.next = null;
			
			_head.next = _tail;
			_tail.prev = _head;
		}
		else
		{
			_head = _head.next;
			_head.prev = null;
			
			_tail.next = t;
			
			t.next = null;
			t.prev = _tail;
			
			_tail = t;
		}
	}
	
	inline public function popDown():Void
	{
		#if debug
		if (size() <= 1)
			throw "list is too small";
		#end
		
		var t:FastDLLNode<T> = _tail;
		if (_tail.prev == _head)
		{
			_tail = _head;
			_tail.next = null;
			
			_head = t;
			_head.prev = null;
			
			_head.next = _tail;
			_tail.prev = _head;
		}
		else
		{
			_tail = _tail.prev;
			_tail.next = null;
			
			_head.prev = t;
			
			t.prev = null;
			t.next = _head;
			
			_head = t;
		}
	}
	
	inline public function nodeOf(val:T, ?from:FastDLLNode<T> = null):FastDLLNode<T>
	{
		#if debug
		if (from != null)
			if (from.list != this)
				throw "node is not part of this list";
		#end
		
		var node:FastDLLNode<T> = from;
		if (node == null) node = _head;
		while (valid(node))
		{
			if (node.val == val) break;
			node = node.next;
		}
		return node;
	}
	
	inline public function lastNodeOf(val:T, ?from:FastDLLNode<T> = null):FastDLLNode<T>
	{
		#if debug
		if (from != null)
			if (from.list != this)
				throw "node is not part of this list";
		#end
		
		var node:FastDLLNode<T> = from;
		if (node == null) node = _tail;
		while (valid(node))
		{
			if (node.val == val) break;
			node = node.prev;
		}
		return node;
	}
	
	inline public function sort(compare:T->T->Int, useInsertionSort:Bool):Void
	{
		if (_size > 1) _head = useInsertionSort ? insertionSort(_head, compare) : mergeSort(_head, compare);
	}
	
	inline public function merge(list:FastDLL<T>):Void
	{
		throw "unsupported operation";
	}
	
	inline public function concat(list:FastDLL<T>):FastDLL<T>
	{
		#if debug
		if (list == this) "list equals given list";
		#end
		
		var c:FastDLL<T> = new FastDLL<T>(_pool.size());
		var walker:FastDLLNode<T> = _head;
		while (valid(walker))
		{
			c.append(walker.val);
			walker = walker.next;
		}
		walker = list.head();
		while (valid(walker))
		{
			c.append(walker.val);
			walker = walker.next;
		}
		
		return c;
	}
	
	inline public function reverse():Void
	{
		if (_size > 1)
		{
			var hook:FastDLLNode<T>;
			var node:FastDLLNode<T> = _tail;
			while (valid(node))
			{
				hook = node.prev;
				
				if (!node.hasNext())
				{
					node.next = node.prev;
					node.prev = null;
					_head = node;
				}
				else
				if (!node.hasPrev())
				{
					node.prev = node.next;
					node.next = null;
					_tail = node;
				}
				else
				{
					var next:FastDLLNode<T> = node.next;
					node.next = node.prev;
					node.prev = next;
				}
				node = hook;
			}
		}
	}
	
	inline public function join(sep:String):String
	{
		var s:String = '';
		if (_size > 0)
		{
			var node:FastDLLNode<T> = head();
			while (node.hasNext())
			{
				s += Std.string(node.val) + sep;
				node = node.next;
			}
			s += Std.string(node.val);
		}
		return s;
	}
	
	inline public function assign(val:T):Void
	{
		var node:FastDLLNode<T> = head();
		while (node.hasNext())
		{
			node.val = val;
			node = node.next;
		}
	}
	
	inline public function factory(cl:Class<T>, args:Array<Dynamic> = null):Void
	{
		if (args == null) args = [];
		var node:FastDLLNode<T> = head();
		while (node.hasNext())
		{
			node.val = Type.createInstance(cl, args);
			node = node.next;
		}
	}
	
	public function toString():String
	{
		#if debug
		var s:String = "\nDLL, size: " + size() + "\n{\n";
		for (i in this) s += "\t" + i + "\n";
		return s += "}";
		#else
		return "{FastDLL, size: " + size() + "}";
		#end
		
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:T):Bool
	{
		for (i in this)
		{
			if (i == val)
				return true;
		}
		return false;
	}
	
	public function clear():Void
	{
		var node:FastDLLNode<T> = _head;
		while (valid(node))
		{
			var next:FastDLLNode<T> = node.next;
			node.next = node.prev = null;
			putNode(node.id);
			node = next;
		}
		_head = _tail = null;
		_size = 0;
	}
	
	public function iterator():Iterator<T>
	{
		return new FastDLLIterator<T>(_head);
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
		var j:Int = 0;
		for (i in this) a[j++] = i;
		return a;
	}

	public function toVector():Vector<T>
	{
		var v:Vector<T> = new Vector<T>();
		var j:Int = 0;
		for (i in this) v[j++] = i;
		return v;
	}

	public function shuffle():Void
	{
		var s:Int = _size, i:Int, t:T;
		while (s > 1)
		{
			s--;
			i = Std.int(Math.random() * s);
			var node1:FastDLLNode<T> = _head;
			for (j in 0...s) node1 = node1.next;
			
			t = node1.val;
			
			var node2:FastDLLNode<T> = _head;
			for (j in 0...i) node2 = node2.next;
			
			node1.val = node2.val;
			node2.val = t;
		}
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		var copy:FastDLL<T> = new FastDLL<T>(_pool.size());
		if (copier == null)
		{
			for (i in this)
				copy.append(i);
		}
		else
		{
			for (i in this)
				copy.append(copier(i));
		}
		return cast copy;
	}
	
	/*///////////////////////////////////////////////////////
	// sort functions
	///////////////////////////////////////////////////////*/
	
	inline private function mergeSort(node:FastDLLNode<T>, compare:T->T->Int):FastDLLNode<T>
	{
		var h:FastDLLNode<T> = node, p:FastDLLNode<T>, q:FastDLLNode<T>, e:FastDLLNode<T>, tail:FastDLLNode<T>;
		var insize:Int = 1, nmerges:Int, psize:Int, qsize:Int, i:Int;
		
		while (true)
		{
			p = h;
			h = tail = null;
			nmerges = 0;
			
			while (valid(p))
			{
				nmerges++;
				
				psize = 0; q = p;
				for (i in 0...insize)
				{
					psize++;
					q = q.next;
					if (q == null) break;
				}
				
				qsize = insize;
				
				while (psize > 0 || (qsize > 0 && valid(q)))
				{
					if (psize == 0)
					{
						e = q; q = q.next; qsize--;
					}
					else
					if (qsize == 0 || q == null)
					{
						e = p; p = p.next; psize--;
					}
					else
					if (compare(p.val, q.val) >= 0)
					{
						e = p; p = p.next; psize--;
					}
					else
					{
						e = q; q = q.next; qsize--;
					}
					
					if (valid(tail))
						tail.next = e;
					else
						h = e;
					
					e.prev = tail;
					tail = e;
				}
				p = q;
			}
			
			node.prev = tail;
			tail.next = null;
			if (nmerges <= 1) break;
			insize <<= 1;
		}
		return h;
	}
	
	inline private function insertionSort(node:FastDLLNode<T>, cmp:T->T->Int):FastDLLNode<T>
	{
		var h:FastDLLNode<T> = node, p:FastDLLNode<T>, n:FastDLLNode<T>, m:FastDLLNode<T>, i:FastDLLNode<T>, val:T;
		n = h.next;
		while (valid(n))
		{
			m = n.next;
			p = n.prev;
			
			if (cmp(p.val, n.val) < 0)
			{
				i = p;
				
				while (i.hasPrev())
				{
					if (cmp(i.prev.val, n.val) < 0)
						i = i.prev;
					else
						break;
				}
				if (valid(m))
				{
					p.next = m;
					m.prev = p;
				}
				else
					p.next = null;
				
				if (i == h)
				{
					n.prev = null;
					n.next = i;
					
					i.prev = n;
					h = n;
				}
				else
				{
					n.prev = i.prev;
					i.prev.next = n;
					
					n.next = i;
					i.prev = n;
				}
			}
			n = m;
		}
		
		return h;
	}
	
	inline private function valid(node:FastDLLNode<T>):Bool
	{
		return node != null;
	}
	
	inline private function getNode(val:T):FastDLLNode<T>
	{
		var id:Int = _pool.get();
		var node:FastDLLNode<T> = _pool.obj();
		node.id = id;
		node.val = val;
		
		#if debug
		node.list = this;
		#end
		
		return node;
	}
	
	inline private function putNode(id:Int):Void
	{
		_pool.put(id);
	}
}

class FastDLLIterator<T> implements haxe.rtti.Generic
{
	private var _walker:FastDLLNode<T>;

	public function new(node:FastDLLNode<T>)
	{
		_walker = node;
	}

	public function hasNext():Bool
	{
		return _walker != null;
	}

	public function next():T
	{
		var val:T = _walker.val;
		_walker = _walker.next;
		return val;
	}
}