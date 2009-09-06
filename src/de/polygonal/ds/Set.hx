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

import flash.Lib;
import flash.utils.Dictionary;
import flash.Vector;

class Set<T> implements haxe.rtti.Generic
{
	private var _set:Dictionary;
	private var _weakKeys:Bool;

	public function new(?weakKeys:Bool = false)
	{
		_set = new Dictionary(_weakKeys = weakKeys);
	}
	
	inline public function has(val:Null<T>):Bool
	{
		#if debug
		if (val == null) throw "invalid value";
		#end
		
		return untyped _set[val] != null;
	}
	
	inline public function set(val:Null<T>):Void
	{
		#if debug
		if (val == null) throw "invalid value";
		#end
		
		untyped _set[val] = val;
	}
	
	inline public function setIfAbsent(val:Null<T>):Bool
	{
		if (!has(val))
		{
			set(val);
			return true;
		}
		else
			return false;
	}
	
	inline public function setAll(s:Set<T>):Void
	{
		for (i in s) set(i);
	}
	
	inline public function remove(val:Null<T>):Void
	{
		#if debug
		if (val == null) throw "invalid value";
		#end
		
		untyped __delete__(_set, val);
	}
	
	public function toString():String
	{
		#if debug
		var s:String = "\nSet, size: " + size() + "\n{\n";
		for (i in this) s += "\t" + i + "\n";
		return s + "}\n";
		#else
		return "{Set, size: " + size() + "}";
		#end
	}
	
	/*///////////////////////////////////////////////////////
	// collection
	///////////////////////////////////////////////////////*/
	
	public function contains(val:T):Bool
	{
		return has(val);
	}

	public function clear():Void
	{
		for (val in this) remove(val);
		_set = new Dictionary(_weakKeys);
	}
	
	public function iterator():Iterator<T>
	{
		return untyped __keys__(_set).iterator();
	}
	
	public function size():Int
	{
		var c:Int = 0;
		for (i in this) c++;
		return c;
	}
	
	public function isEmpty():Bool
	{
		return size() == 0;
	}

	public function toArray():Array<T>
	{
		var a:Array<T> = new Array<T>();
		var i:Int = 0;
		for (val in this) a[i++] = val;
		return a;
	}
	
	public function toVector():Vector<T>
	{
		var v:Vector<T> = new Vector<T>(size(), true);
		var i:Int = 0;
		for (val in this) v[i++] = val;
		return v;
	}
	
	public function shuffle():Void
	{
		throw "unsupported operation";
	}
	
	public function clone(copier:T->T):Set<T>
	{
		var copy:Set<T> = new Set<T>(_weakKeys);
		if (copier == null)
		{
			for (i in this)
				untyped copy.set(_set[i]);
		}
		else
		{
			for (i in this)
				untyped copy.set(copier(_set[i]));
		}
		
		return copy;
	}
}
