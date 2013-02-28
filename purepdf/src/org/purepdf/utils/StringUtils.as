/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: StringUtils.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/utils/StringUtils.as $
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
package org.purepdf.utils
{
	public class StringUtils
	{
		private static const EMPTY_CHAR: Vector.<int> = Vector.<int>([ 9, 32, 10, 13 ]);
		
		public static function appendChars( src: String, chars: Vector.<int>, offset: int, len: int ): void
		{
			for( var k: int = offset; k < ( offset + len ); ++k )
			{
				src += String.fromCharCode( chars[k] & 0xff );
			}
		}
		
		public static function toCharArray( s: String ): Vector.<int>
		{
			var r: Vector.<int> = new Vector.<int>( s.length );
			for( var k: int = 0; k < s.length; ++k )
			{
				r[k] = s.charCodeAt(k);
			}
			return r;
		}
		
		public static function padLeft( p_string: String, p_padChar: String, p_length: uint ): String
		{
			var s: String = p_string;
			if( p_string.length < p_length )
			{
				while(s.length < p_length) 
					s = p_padChar + s; 
			}
			return s;
		}
		
		public static function startsWith( src: String, value: String ): Boolean
		{
			return src.indexOf( value ) == 0;
		}
		
		public static function endsWith( src: String, value: String ): Boolean
		{
			var index: int = src.lastIndexOf( value );
			if( index > -1 )
				return (index + value.length) == src.length;
			return false;
		}
		
		public static function left_trim( value: String ): String
		{
			if( EMPTY_CHAR.indexOf( value.charCodeAt(0) ) > -1 )
				value = left_trim( value.substr( 1 ) );
			
			return value;
		}
		
		public static function right_trim( value: String ): String
		{
			if( EMPTY_CHAR.indexOf( value.charCodeAt( value.length - 1 ) ) > -1 )
				value = left_trim( value.substr( 0, value.length - 1 ) );
		
			return value;
		}
		
		public static function trim( value: String ): String
		{
			return right_trim( left_trim( value ) );
		}
	}
}