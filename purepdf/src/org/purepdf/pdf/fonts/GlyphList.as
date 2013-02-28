/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: GlyphList.as 356 2010-03-11 17:33:13Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 356 $ $LastChangedDate: 2010-03-11 12:33:13 -0500 (Thu, 11 Mar 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/GlyphList.as $
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
package org.purepdf.pdf.fonts
{
	import flash.utils.ByteArray;
	
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.ObjectHash;
	
	public class GlyphList extends ObjectHash
	{
		[Embed(source="names2unicode.bytearray", mimeType="application/octet-stream")]
		private static var n2u: Class;
		
		[Embed(source="unicode2names.bytearray", mimeType="application/octet-stream")]
		private static var u2n: Class;
		
		private static var _unicode2names: HashMap;
		private static var _names2unicode: HashMap;
		
		private static function init_names2unicode( b: ByteArray ): void
		{
			_names2unicode = b.readObject();
		}
		
		private static function init_unicode2names( b: ByteArray ): void
		{
			_unicode2names = b.readObject();
		}
		
		public static function setUnicode2Names( value: ByteArray ): void
		{
			init_unicode2names( value );
		}
		
		public static function setNames2Unicode( value: ByteArray ): void
		{
			init_names2unicode( value );
		}
		
		public static function name2unicode( name: String ): Vector.<int>
		{
			if( _names2unicode == null )
			{
				var byte: ByteArray = new n2u() as ByteArray;
				byte.uncompress();
				init_names2unicode( byte );
			}
			
			return Vector.<int>( _names2unicode.getValue( name ) );
		}
		
		public static function unicode2name( num: int ): String
		{
			if( _unicode2names == null )
			{
				var byte: ByteArray = new u2n() as ByteArray;
				byte.uncompress();
				init_unicode2names( byte );
			}
			
			return _unicode2names.getValue( num ) as String;
		}
		
	}
}