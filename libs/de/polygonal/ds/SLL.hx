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

class SLL<T> implements haxe.rtti.Generic
{
	private var _head:SLLNode<T>;
	private var _tail:SLLNode<T>;
	
	private var _size:Int;
	
	public function new()
	{
		_head = null;
		_size = 0;
	}
	
	inline public function head():SLLNode<T>
	{
		return _head;
	}
	
	inline public function tail():SLLNode<T>
	{
		return _tail;
	}
	
	inline public function append(val:T):SLLNode<T>
	{
		var node:SLLNode<T> = getNode(val);
		if (valid(_tail))
			_tail.next = node;
		else
			_head = node;
		
		_tail = node;
		
		_size++;
		return node;
	}
	
	inline public function prepend(val:T):SLLNode<T>
	{
		var node:SLLNode<T> = getNode(val);
		
		if (valid(_tail))
		{
			node.next = _head;
			_head = node;
		}
		else
		{
			_head = _tail = node;
		}
		
		_size++;
		return node;
	}
	
	inline public function insertAfter(node:SLLNode<T>, val:T):SLLNode<T>
	{
		#if debug
		if (node == null) "node is null";
		if (node.getList() != this)
			throw "node is not part of this list";
		#end
		
		var t:SLLNode<T> = new SLLNode<T>(val, this);
		node.insertAfter(t);
		if (node == _tail) _tail = t;
		_size++;
		return t;
	}
	
	inline public function remove(node:SLLNode<T>):Void
	{
		#if debug
		if (isEmpty())
			throw "list is empty";
		if (node.getList() != this)
			throw "node is not part of this list";
		#end
		
		if (node == _head)
			removeHead();
		else
		{
			var t:SLLNode<T> = getNodeBefore(node);
			if (t.next == _tail) _tail = t;
			t.next = node.next;
			_size--;
		}
	}
	
	inline public function getNodeAt(i:Int):SLLNode<T>
	{
		#if debug
		if (i < 0 || i >= _size) throw "index out of bounds";
		#end
		
		var node:SLLNode<T> = _head;
		for (j in 0...i) node = node.next;
		return node;
	}
	
	inline public function removeHead():T
	{
		#if debug
		if (isEmpty()) throw "list is empty";
		#end
		
		var node:SLLNode<T> = _head;
		
		if (_size > 1)
		{
			_head = _head.next;
			node.next = null;
			if (_head == null) _tail = null;
			_size--;
		}
		else
		{
			_head = _tail = null;
			_size = 0;
		}
		
		return node.val;
	}
	
	inline public function removeTail():T
	{
		#if debug
		if (isEmpty()) throw "list is empty";
		#end
		
		var val:T = _tail.val;
		
		if (_size > 1)
		{
			var node:SLLNode<T> = getNodeBefore(_tail);
			_tail = node;
			node.next = null;
			_size--;
		}
		else
		{
			_head = _tail = null;
			_size = 0;
		}
		
		return val;
	}
	
	inline public function shiftUp():Void
	{
		var t:SLLNode<T> = _head;
		if (_head.next == _tail)
		{
			_head = _tail;
			_tail = t;
			_tail.next = null;
			_head.next = _tail;
		}
		else
		{
			_head = _head.next;
			_tail.next = t;
			t.next = null;
			_tail = t;
		}
	}
	
	inline public function popDown():Void
	{
		var t:SLLNode<T> = _tail;
		if (_head.next == _tail)
		{
			_tail = _head;
			_head = t;
			
			_tail.next = null;
			_head.next = _tail;
		}
		else
		{
			var node:SLLNode<T> = _head;
			while (node.next != _tail)
				node = node.next;
			
			_tail = node;
			_tail.next = null;
			
			t.next = _head;
			_head = t;
		}
	}
	
	inline public function nodeOf(val:T, ?from:SLLNode<T> = null):SLLNode<T>
	{
		#if debug
		if (from != null)
			if (from.getList() != this)
				throw "node is not part of this list";
		#end
		
		var node:SLLNode<T> = from;
		if (node == null) node = _head;
		while (valid(node))
		{
			if (node.val == val) break;
			node = node.next;
		}
		return node;
	}
	
	inline public function sort(compare:T->T->Int, ?useInsertionSort:Bool = false):Void
	{
		if (_size > 1) _head = useInsertionSort ? insertionSort(_head, compare) : mergeSort(_head, compare);
	}
	
	inline public function merge(list:SLL<T>):Void
	{
		if (valid(list.head()))
		{
			if (valid(_head))
			{
				_tail.next = list.head();
				_tail = list.tail();
			}
			else
			{
				_head = list.head();
				_tail = list.tail();
			}
			_size += list.size();
		}
	}
	
	inline public function concat(list:SLL<T>):SLL<T>
	{
		#if debug
		if (list == this) "list equals given list";
		#end
		
		var c:SLL<T> = new SLL<T>();
		var walker:SLLNode<T> = _head;
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
			var v:Vector<T> = new Vector<T>(_size, true);
			var i:Int = 0;
			var node:SLLNode<T> = _head;
			while (valid(node))
			{
				v[i++] = node.val;
				node = node.next;
			}
			
			v.reverse();
			
			i = 0;
			var node:SLLNode<T> = _head;
			while (valid(node))
			{
				node.val = v[i++];
				node = node.next;
			}
		}
	}
	
	inline public function join(sep:String):String
	{
		var s:String = '';
		if (_size > 0)
		{
			var node:SLLNode<T> = head();
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
		var walker = _head;
		while (walker != null)
		{
			walker.val = val;
			walker = walker.next;
		}
	}
	
	inline public function factory(cl:Class<T>, args:Array<Dynamic> = null):Void
	{
		if (args == null) args = [];
		var walker = _head;
		while (walker != null)
		{
			walker.val = Type.createInstance(cl, args);
			walker = walker.next;
		}
	}
	
	public function toString():String
	{
		#if debug
		var s:String = "\nSLL, size: " + size() + "\n{\n";
		for (i in this) s += "\t" + i + "\n";
		return s += "}";
		#else
		return "{SLL, size: " + size() + "}";
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
		var node:SLLNode<T> = _head;
		while (valid(node))
		{
			var next:SLLNode<T> = node.next;
			node.next = null;
			node = next;
		}
		
		_head = _tail = null;
		_size = 0;
	}
	
	public function iterator():Iterator<T>
	{
		return new SLLIterator<T>(_head);
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
			var node1:SLLNode<T> = _head;
			for (j in 0...s) node1 = node1.next;
			
			t = node1.val;
			
			var node2:SLLNode<T> = _head;
			for (j in 0...i) node2 = node2.next;
			
			node1.val = node2.val;
			node2.val = t;
		}
	}
	
	public function clone(copier:T->T):Collection<T>
	{
		var copy:SLL<T> = new SLL<T>();
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
	
	inline private function mergeSort(node:SLLNode<T>, cmp:T->T->Int):SLLNode<T>
	{
		var h:SLLNode<T> = node, p:SLLNode<T>, q:SLLNode<T>, e:SLLNode<T>, tail:SLLNode<T>;
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
					if (cmp(p.val, q.val) >= 0)
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
					
					tail = e;
				}
				p = q;
			}
			
			tail.next = null;
			if (nmerges <= 1) break;
			insize <<= 1;
		}
		
		return h;
	}
	
	inline private function insertionSort(node:SLLNode<T>, cmp:T->T->Int):SLLNode<T>
	{
		var v:Vector<T> = new Vector<T>(_size, true);
		var i:Int = 0;
		var t:SLLNode<T> = node;
		while (valid(t))
		{
			v[i++] = t.val;
			t = t.next;
		}
		
		var h:SLLNode<T> = node;
		
		var val:T;
		var j:Int;
		for (i in 1..._size)
		{
			val = v[i];
			j = i;
			while ((j > 0) && (cmp(v[j - 1], val) < 0))
			{
				v[j] = v[j - 1];
				j--;
			}
			v[j] = val;
		}
		
		t = h;
		i = 0;
		while (valid(t))
		{
			t.val = v[i++];
			t = t.next;
		}
		return h;
	}
	
	/*///////////////////////////////////////////////////////
	// helpers
	///////////////////////////////////////////////////////*/
	
	inline private function valid(node:SLLNode<T>):Bool
	{
		return node != null;
	}
	
	inline private function getNode(val:T):SLLNode<T>
	{
		return new SLLNode<T>(val, this);
	}

	inline private function getNodeBefore(node:SLLNode<T>):SLLNode<T>
	{
		var walker:SLLNode<T> = _head;
		while (walker.next != node)
			walker = walker.next;
		return walker;
	}
}

class SLLIterator<T> implements haxe.rtti.Generic
{
	private var _walker:SLLNode<T>;

	public function new(node:SLLNode<T>)
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