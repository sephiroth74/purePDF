/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: ByteArrayInputStream.as 368 2010-05-07 02:14:55Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 368 $ $LastChangedDate: 2010-05-06 22:14:55 -0400 (Thu, 06 May 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/io/ByteArrayInputStream.as $
*
* The contents of this file are subject to  LGPL license 
* (the "GNU LIBRARY GENERAL PUBLIC LICENSE"), in which case the
* provisions of LGPL are applicable instead of those above.  If you wish to
* allow use of your version of this file only under the terms of the LGPL
* License and not to allow others to use your version of this file under
* the MPL, indicate your decision by deleting the provisions above and
* replace them with the notice and other provisions required by the LGPL.
* If you do not delete the provisions above, a recipient may use your version
* of this file under either the MPL or the GNU LIBRARY GENERAL PUBLIC LICENSE
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the License.
*
* The Original Code is 'iText, a free JAVA-PDF library' ( version 4.2 ) by Bruno Lowagie.
* All the Actionscript ported code and all the modifications to the
* original java library are written by Alessandro Crugnola (alessandro@sephiroth.it)
*
* This library is free software; you can redistribute it and/or modify it
* under the terms of the MPL as stated above or under the terms of the GNU
* Library General Public License as published by the Free Software Foundation;
* either version 2 of the License, or any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU LIBRARY GENERAL PUBLIC LICENSE for more
* details
*
* If you didn't download this code from the following link, you should check if
* you aren't using an obsolete version:
* http://code.google.com/p/purepdf
*
*/
package org.purepdf.io
{
	import flash.utils.ByteArray;
	
	import org.purepdf.errors.IndexOutOfBoundsError;
	import org.purepdf.errors.NullPointerError;

	public class ByteArrayInputStream implements InputStream
	{
		protected var buf: ByteArray;
		protected var count: int;
		protected var mark: int = 0;
		protected var pos: int;

		public function ByteArrayInputStream( ins: ByteArray, offset: int = 0, lenght: int = 0 )
		{
			if ( lenght == 0 )
				lenght = ins.length;
			buf = ins;
			pos = offset;
			count = Math.min( offset + lenght, buf.length );
			mark = offset;
		}
		
		public function get size(): int
		{
			return count;
		}
		
		public function get position(): int
		{
			return pos;
		}
		
		public function get available(): int
		{
			return count - pos;
		}
		
		public function get bytearray(): ByteArray
		{
			return buf;
		}

		public function readBytes( b: ByteArray, off: int, len: int ): int
		{
			if ( b == null )
			{
				throw new NullPointerError();
			} else if ( off < 0 || len < 0 || len > b.length - off )
			{
				throw new IndexOutOfBoundsError();
			}

			if ( pos >= count )
			{
				return -1;
			}

			if ( pos + len > count )
			{
				len = count - pos;
			}

			if ( len <= 0 )
			{
				return 0;
			}
			
			buf.position = pos;
			buf.readBytes( b, off, len );
			
			pos += len;
			return len;
		}

		public function readUnsignedByte(): int
		{
			return ( pos < count ) ? ( buf[ pos++ ] & 0xFF ) : -1;
		}

		public function skip( n: Number ): Number
		{
			if ( pos + n > count )
			{
				n = count - pos;
			}

			if ( n < 0 )
			{
				return 0;
			}
			pos += n;
			return n;
		}
	}
}