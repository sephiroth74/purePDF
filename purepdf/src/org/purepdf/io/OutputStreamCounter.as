/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: OutputStreamCounter.as 260 2010-02-04 13:36:32Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 260 $ $LastChangedDate: 2010-02-04 08:36:32 -0500 (Thu, 04 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/io/OutputStreamCounter.as $
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
	
	import org.purepdf.pdf.interfaces.IOutputStream;
	import org.purepdf.utils.Bytes;
	
	public class OutputStreamCounter implements IOutputStream
	{
		protected var out: ByteArray;
		protected var counter: int = 0;
		
		public function OutputStreamCounter( $out: ByteArray )
		{
			out = $out;
		}
		
		public function getCounter(): int
		{
			return counter;
		}
		
		public function resetCounter(): void
		{
			counter = 0;
		}
		
		public function getInternalBuffer(): ByteArray
		{
			return out;
		}
		
		public function writeByteArray( value: ByteArray, off: int = 0, len: int = 0 ): void
		{
			if( value == null ) 
				throw new Error('NullPointerException');
			
			if( len == 0 ) len = value.length;
			
			if( (off < 0) || (off > value.length) || (len < 0) || ((off + len) > value.length) || ((off + len) < 0) )
				throw new Error('IndexOutOfBoundsException');
			else if( len == 0 )
				return;
			
			counter += len;
			out.writeBytes( value, off, len );
			
			value.position = off;
		}
		
		public function toBytes(): Bytes
		{
			var b: Bytes = new Bytes();
			b.buffer.writeBytes( this.out );
			return b;
		}
		
		public function writeBytes( value: Bytes, off: int = 0, len: int = 0 ): void
		{
			writeByteArray( value.buffer, off, len );
		}
		
		public function writeInt( value: int ): void
		{
			++counter;
			out[out.position++] = value;
		}
		
	}
}