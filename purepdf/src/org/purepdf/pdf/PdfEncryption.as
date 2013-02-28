/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfEncryption.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfEncryption.as $
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
package org.purepdf.pdf
{
	import com.adobe.crypto.MD5;
	
	import flash.system.System;
	
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.utils.Bytes;

	public class PdfEncryption extends ObjectHash
	{
		private static var seq: Number = new Date().getTime();
		
		public static const STANDARD_ENCRYPTION_40: int = 2;
		public static const STANDARD_ENCRYPTION_128: int = 3;
		public static const AES_128: int = 4;
		
		private var revision: int;
		private var _embeddedFilesOnly: Boolean;
		
		public function PdfEncryption()
		{
		}
		
		public function calculateStreamSize( n: int ): int
		{
			if( revision == AES_128 )
				return (n & 0x7ffffff0) + 32;
			else
				return n;
		}
		
		public function encryptByteArray( b: Bytes ): Bytes
		{
			throw new NonImplementatioError("PdfEncryption.enctryptBytes not yet implemented");
		}
		
		/**
		 * Indicates if only the embedded files have to be encrypted.
		 * @return	if true only the embedded files will be encrypted
		 */
		public function get embeddedFilesOnly(): Boolean 
		{
			return _embeddedFilesOnly;
		}

		
		public static function createInfoId( id: Bytes ): PdfObject
		{
			var buf: ByteBuffer = new ByteBuffer();
			var k: int;
			
			buf.append_char('[').append_char('<');
			
			for( k = 0; k < 16; ++k )
				buf.appendHex( id[k] );
			
			buf.append_char('>').append_char('<');
			id = createDocumentId();
			
			for( k = 0; k < 16; ++k )
				buf.appendHex( id[k] );
			
			buf.append_char('>').append_char(']');
			
			return new PdfLiteral( buf.toString() );
		}
		
		public static function createDocumentId(): Bytes
		{
			var time: Number = new Date().getTime();
			var mem: Number = System.totalMemory;
			var s: String = time + "+" + mem + (seq++);
			return PdfWriter.getISOBytes( MD5.hash( s ) );
		}
	}
}