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

class ArrayedInsertionSort
{
	inline public static function sortVectorCmp<T>(v:Vector<T>, cmp:T->T->Int):Void
	{
		var j:Int, val:T;
		for (i in 1...v.length)
		{
			val = v[i]; j = i;
			while ((j > 0) && cmp(v[j - 1], val) < 0)
			{
				v[j] = v[j - 1];
				j--;
			}
			v[j] = val;
		}
	}
	
	inline public static function sortVectorInt(v:Vector<Int>):Void
	{
		var j:Int, val:Int;
		for (i in 1...v.length)
		{
			val = v[i]; j = i;
			while ((j > 0) && (v[j - 1] > val))
			{
				v[j] = v[j - 1];
				j--;
			}
			v[j] = val;
		}
	}
	
	inline public static function sortVectorFloat(v:Vector<Float>):Void
	{
		var j:Int, val:Float;
		for (i in 1...v.length)
		{
			val = v[i]; j = i;
			while ((j > 0) && (v[j - 1] > val))
			{
				v[j] = v[j - 1];
				j--;
			}
			v[j] = val;
		}
	}
}