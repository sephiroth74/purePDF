/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: FontSelector.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/FontSelector.as $
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
	import org.purepdf.Font;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Phrase;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.StringUtils;
	import org.purepdf.utils.Utilities;

	public class FontSelector
	{
		protected var fonts: Vector.<Font> = new Vector.<Font>();
		
		public function FontSelector()
		{
		}
		
		/**
		 * Process the text so that it will render with a combination of fonts
		 * if needed.
		 */    
		public function process( text: String ): Phrase
		{
			var fsize: int = fonts.length;
			if (fsize == 0)
				throw new TypeError("no font is defined");
			
			var cc: Vector.<int> = StringUtils.toCharArray( text );
			var len: int = cc.length;
			var sb: String = "";
			var font: Font = null;
			var lastidx: int = -1;
			var f: int;
			var ck: Chunk;
			var ret: Phrase = new Phrase(null,null);
			
			for (var k: int = 0; k < len; ++k )
			{
				var c: int = cc[k];
				if( c == 10 || c == 13 ) {
					sb += String.fromCharCode( c );
					continue;
				}
				
				if( Utilities.isSurrogatePair(cc, k) )
				{
					var u: int = Utilities.convertToUtf32_3(cc, k);
					
					for( f = 0; f < fsize; ++f )
					{
						font = fonts[f];
						if( font.baseFont.charExists(u) )
						{
							if( lastidx != f )
							{
								if( sb.length > 0 && lastidx != -1 )
								{
									ck = new Chunk( sb, fonts[lastidx] );
									ret.add(ck);
									sb = "";
								}
								lastidx = f;
							}
							sb += String.fromCharCode(c);
							sb += String.fromCharCode(cc[++k]);
							break;
						}
					}
				}
				else {
					for ( f = 0; f < fsize; ++f )
					{
						font = fonts[f];
						if ( font.baseFont.charExists(c)) {
							if (lastidx != f) {
								if (sb.length > 0 && lastidx != -1) {
									ck = new Chunk( sb, fonts[lastidx]);
									ret.add(ck);
									sb = "";
								}
								lastidx = f;
							}
							sb += String.fromCharCode(c);
							break;
						}
					}
				}
			}
			if (sb.length > 0) {
				ck = new Chunk(sb, fonts[lastidx == -1 ? 0 : lastidx] );
				ret.add(ck);
			}
			return ret;
		}
		
		public function addFont( value: Font ): void
		{
			if( value.baseFont != null )
			{
				fonts.push( value );
				return;
			}
			
			var bf: BaseFont = value.getCalculatedBaseFont(true);
			var f2: Font = Font.fromBaseFont( bf, value.size, value.getCalculatedSize(), value.color );
			fonts.push( f2 );
		}
	}
}