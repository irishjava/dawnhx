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

class Compare
{
	public static function compareNumberFall<T>(a:T, b:T):Int
	{
		return untyped a - b;
	}
	
	public static function compareNumberRise<T>(a:T, b:T):Int
	{
		return untyped b - a;
	}
	
	public static function compareStringCaseInSensitiveFall<T>(a:T, b:T):Int
	{
		untyped
		{
			a = a.toLowerCase();
			b = b.toLowerCase();
			
			if (a.length + b.length > 2)
			{
				var r:Int = 0;
				var k:Int = a.length > b.length ? a.length : b.length;
				for (i in 0...k)
				{
					r = a.charCodeAt(i) - b.charCodeAt(i);
					if (r != 0)	break;
				}
				return r;
			}
			else
				return a.charCodeAt(0) - b.charCodeAt(0);
		}
	}
	
	public static function compareStringCaseInSensitiveRise<T>(a:T, b:T):Int
	{
		return compareStringCaseInSensitiveFall(b, a);
	}
	
	public static function compareStringCaseSensitiveFall<T>(a:T, b:T):Int
	{
		untyped
		{
			if (a.length + b.length > 2)
			{
				var r:Int = 0;
				var k:Int = a.length > b.length ? a.length : b.length;
				for (i in 0...k)
				{
					r = a.charCodeAt(i) - b.charCodeAt(i);
					if (r != 0)	break;
				}
				return r;
			}
			else
				return a.charCodeAt(0) - b.charCodeAt(0);
		}
	}
	
	public static function compareStringCaseSensitiveRise(a:String, b:String):Int
	{
		return compareStringCaseSensitiveFall(b, a);
	}
}