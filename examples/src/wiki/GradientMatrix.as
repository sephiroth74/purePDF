/*
GradientMatrix
Fixes the native implementation of Flash's matrix.createGradientBox()
which does not work as intended with rotated gradients

released under MIT License (X11)
http://www.opensource.org/licenses/mit-license.php

Author: Mario Klingemann
http://www.quasimondo.com

Modified by Alessandro Crugnola
http://www.sephiroth.it

Copyright (c) 2009 Mario Klingemann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package wiki
{
	import flash.geom.Matrix;

	public class GradientMatrix
	{
		public static function getGradientBox( width: Number, height: Number, rotation: Number, tx: Number, ty: Number ): Matrix
		{
			var m: Matrix = new Matrix();
			m.createGradientBox( 100, 100 );
			m.translate( -50, -50 );
			m.scale( width / 100, height / 100 );
			m.rotate( rotation );
			m.translate( 50*(width/100), 50*(height/100) );
			m.translate( tx, ty );
			return m;
		}
	}
}