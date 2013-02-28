/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfEncodings.as 386 2011-01-12 14:05:20Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 386 $ $LastChangedDate: 2011-01-12 09:05:20 -0500 (Wed, 12 Jan 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfEncodings.as $
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
	import flash.errors.IOError;
	
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.errors.ConversionError;
	import org.purepdf.pdf.encoding.Cp437Conversion;
	import org.purepdf.pdf.encoding.ExtraEncoding;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.ByteArrayUtils;
	import org.purepdf.utils.Bytes;

	public class PdfEncodings extends ObjectHash
	{
		private static const pdfEncodingByteToChar: Vector.<int> = Vector.<int>( [
			0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
			16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
			32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
			48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
			64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
			80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 
			96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 
			112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 
			0x2022, 0x2020, 0x2021, 0x2026, 0x2014, 0x2013, 0x0192, 0x2044, 0x2039, 0x203a, 0x2212, 0x2030, 0x201e, 0x201c, 0x201d, 0x2018,
			0x2019, 0x201a, 0x2122, 0xfb01, 0xfb02, 0x0141, 0x0152, 0x0160, 0x0178, 0x017d, 0x0131, 0x0142, 0x0153, 0x0161, 0x017e, 65533,
			0x20ac, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 
			176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 
			192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 
			208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 
			224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 
			240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255 ] );
		
		private static const winansiByteToChar: Vector.<int> = Vector.<int>([
			0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
			16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 
			32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 
			48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 
			64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
			80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 
			96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 
			112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 
			8364, 65533, 8218, 402, 8222, 8230, 8224, 8225, 710, 8240, 352, 8249, 338, 65533, 381, 65533, 
			65533, 8216, 8217, 8220, 8221, 8226, 8211, 8212, 732, 8482, 353, 8250, 339, 65533, 382, 376, 
			160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 
			176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 
			192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 
			208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 
			224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 
			240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255]);
		
		private static var _pdfEncoding: Object;
		private static var _winansi: Object;
		private static var _extraEncodings: HashMap;
		
		private static function get extraEncodings(): HashMap
		{
			if( _extraEncodings == null )
				init_extra();
			return _extraEncodings;
		}
		
		private static function init(): void
		{
			var k: int;
			var c: int;
			
			_pdfEncoding = new Object();
			_winansi = new Object();
			
			for( k = 128; k < 161; ++k )
			{
				c = winansiByteToChar[ k ];
				if( c != 65533 )
					_winansi[c] = k;
			}
			
			for( k = 128; k < 161; ++k )
			{
				c = pdfEncodingByteToChar[k];
				if( c != 65533 )
					_pdfEncoding[c] = k;
			}
		}
		
		private static function init_extra(): void
		{
			_extraEncodings = new HashMap();
			_extraEncodings.put("cp437", new Cp437Conversion() );
		}
		
		public static function get pdfEncoding(): Object
		{
			if( _pdfEncoding == null )
				init();
			return _pdfEncoding;
		}
		
		public static function get winansi(): Object
		{
			if( _winansi == null )
				init();
			return _winansi;
		}
		
		public static function convertToByte( char1: int, encoding: String ): Bytes 
		{
			var result: Bytes = new Bytes();
			if( encoding == null || encoding.length == 0)
			{
				result[0] = ByteBuffer.intToByte( char1 );
			}
			
			var hash: Object;
			
			if( encoding == BaseFont.WINANSI)
				hash = winansi;
			else if( encoding == PdfObject.TEXT_PDFDOCENCODING )
				hash = pdfEncoding;
			
			if( hash != null )
			{
				var c: int = 0;
				if (char1 < 128 || (char1 > 160 && char1 <= 255))
					c = char1;
				else
					c = hash[char1];
				if (c != 0)
				{
					result[0] = ByteBuffer.intToByte(c);
					return result;
				} else
				{
					return new Bytes(0);
				}
			}
			if( encoding == PdfObject.TEXT_UNICODE )
			{
				var b: Bytes = new Bytes(4);
				b[0] = -2;
				b[1] = -1;
				b[2] = (char1 >> 8);
				b[3] = (char1 & 0xff);
				return b;
			}
			/*
			try {
				return String.valueOf(char1).getBytes(encoding);
			}
			catch (UnsupportedEncodingException e) {
				throw new ExceptionConverter(e);
			}*/
			throw new ConversionError();
		}
		
		public static function convertToBytes( text: String, encoding: String ): Bytes
		{
			var byte: Bytes;
			var len: int;
			var k: int;
			
			if( text == null )
			{
				byte = new Bytes();
				return byte;
			}
			
			if( encoding == null || encoding.length == 0 ){
				len = text.length;
				byte = new Bytes();
				for( k = 0; k < len; ++k )
					byte[k] = ByteBuffer.intToByte( text.charCodeAt(k) );
				return byte;
			}
			
			var extra: ExtraEncoding = extraEncodings.getValue( encoding.toLowerCase() ) as ExtraEncoding;
			if (extra != null) 
			{
				byte = extra.charToByte( text, encoding );
				if( byte != null )
					return byte;
			}
			
			
			var hash: Object;
			
			if( encoding == BaseFont.WINANSI )
				hash = winansi;
			else if( encoding == PdfObject.TEXT_PDFDOCENCODING )
				hash = pdfEncoding;
			
			if( hash != null )
			{
				byte = new Bytes();
				len = text.length;
				var ptr: int = 0;
				var c: int = 0;
				var code: Number;
				
				for( k = 0; k < len; ++k )
				{
					code = text.charCodeAt(k);
					if( code < 128 || ( code > 160 && code <= 255 ) )
						c = code;
					else
						c = hash[code];
					if( c != 0 )
					{
						byte[ptr++] = c;
					}
				}
				
				if( ptr == len )
					return byte;
				
				var b2: Bytes = new Bytes();
				b2.writeBytes( byte, 0, ptr );
				return b2;
			}
			
			if( encoding == PdfObject.TEXT_UNICODE )
			{
				byte = new Bytes();
				try
				{
					byte.buffer.writeMultiByte( text, "unicode" );
					return byte;
				} catch( e: Error )
				{
					throw e;
				}
			}
			
			try
			{
				trace('convertToBytes with encoding ' + encoding ); 
				byte = new Bytes();
				byte.buffer.writeMultiByte( text, ByteArrayUtils.getEncoding( encoding ) );
				byte.position = 0;
				
				return byte;
			} catch( e: Error )
			{
				throw e;
			}
			
			return byte;
		}
		
		public static function convertToString( bytes: Bytes, encoding: String ): String
		{
			if( bytes == null )
				return PdfObject.NOTHING;
			
			var k: int;
			var c: String;
			
			if( encoding == null || encoding.length == 0 )
			{
				c = "";
				for( k = 0; k < bytes.length; k++ )
				{
					var byte: int = bytes[k];
					c += String.fromCharCode( byte & 0xff );
				}
				return c;
			}
			
			var ch: Vector.<int> = null;
			
			if( encoding == BaseFont.WINANSI )
				ch = winansiByteToChar;
			else if( encoding == PdfObject.TEXT_PDFDOCENCODING )
				ch = pdfEncodingByteToChar;
			
			var extra: ExtraEncoding = extraEncodings.getValue( encoding.toLowerCase() ) as ExtraEncoding;
			if (extra != null) 
			{
				var text: String = extra.byteToChar( bytes, encoding );
				if( text != null )
					return text;
			}
			
			if( ch != null ){
				var len: int = bytes.length;
				c = "";
				for( k = 0; k < len; ++k )
				{
					c += String.fromCharCode( ch[ bytes[k] & 0xff ] );
				}
				return c;
			}
			
			throw new IOError("Invalid encoding");
			return null;
		}
		
		public static function isPdfDocEncoding( text: String ): Boolean
		{
			if( text == null )
				return true;
			
			var len: int = text.length;
			for( var k: int = 0; k < len; k++ )
			{
				var char1: String = text.charAt( k );
				var code1: Number = char1.charCodeAt( 0 );
				
				if( code1 < 128 || ( code1 > 160 && code1 <= 255 ) )
					continue;
				
				if( !pdfEncoding[code1] )
					return false;
			}
			return true;
		}
	}
}