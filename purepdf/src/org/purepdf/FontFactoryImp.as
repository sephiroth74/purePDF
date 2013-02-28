/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: FontFactoryImp.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/FontFactoryImp.as $
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
package org.purepdf
{
	import flash.utils.Dictionary;
	
	import it.sephiroth.utils.HashMap;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.fonts.BaseFont;
	
	public class FontFactoryImp implements IFontProvider
	{
		private var trueTypeFonts: Dictionary = new Dictionary( false );
		private var fontFamilies: HashMap = new HashMap();
		public var defaultEncoding: String = BaseFont.WINANSI;
		public var defaultEmbedding: Boolean = BaseFont.NOT_EMBEDDED;
		
		public function FontFactoryImp()
		{
			// register all true type fonts
			trueTypeFonts[ BaseFont.COURIER.toLowerCase() ] = BaseFont.COURIER;
			trueTypeFonts[ BaseFont.COURIER_BOLD.toLowerCase() ] = BaseFont.COURIER_BOLD;
			trueTypeFonts[ BaseFont.COURIER_BOLDOBLIQUE.toLowerCase() ] = BaseFont.COURIER_BOLDOBLIQUE;
			trueTypeFonts[ BaseFont.COURIER_OBLIQUE.toLowerCase() ] = BaseFont.COURIER_OBLIQUE;
			trueTypeFonts[ BaseFont.HELVETICA.toLowerCase() ] = BaseFont.HELVETICA;
			trueTypeFonts[ BaseFont.HELVETICA_BOLD.toLowerCase() ] = BaseFont.HELVETICA_BOLD;
			trueTypeFonts[ BaseFont.HELVETICA_BOLDOBLIQUE.toLowerCase() ] = BaseFont.HELVETICA_BOLDOBLIQUE;
			trueTypeFonts[ BaseFont.HELVETICA_OBLIQUE.toLowerCase() ] = BaseFont.HELVETICA_OBLIQUE;
			trueTypeFonts[ BaseFont.SYMBOL.toLowerCase() ] = BaseFont.SYMBOL;
			trueTypeFonts[ BaseFont.TIMES_BOLD.toLowerCase() ] = BaseFont.TIMES_BOLD;
			trueTypeFonts[ BaseFont.TIMES_BOLDITALIC.toLowerCase() ] = BaseFont.TIMES_BOLDITALIC;
			trueTypeFonts[ BaseFont.TIMES_ITALIC.toLowerCase() ] = BaseFont.TIMES_ITALIC;
			trueTypeFonts[ BaseFont.TIMES_ROMAN.toLowerCase() ] = BaseFont.TIMES_ROMAN;
			trueTypeFonts[ BaseFont.ZAPFDINGBATS.toLowerCase() ] = BaseFont.ZAPFDINGBATS;
			
			// courier
			var tmp: Vector.<String> = new Vector.<String>();
			tmp.push( BaseFont.COURIER );
			tmp.push( BaseFont.COURIER_BOLD );
			tmp.push( BaseFont.COURIER_BOLDOBLIQUE );
			tmp.push( BaseFont.COURIER_OBLIQUE );
			fontFamilies.put( BaseFont.COURIER.toLowerCase(), tmp );
			
			// helvetica
			tmp = new Vector.<String>();
			tmp.push( BaseFont.HELVETICA );
			tmp.push( BaseFont.HELVETICA_BOLD );
			tmp.push( BaseFont.HELVETICA_BOLDOBLIQUE );
			tmp.push( BaseFont.HELVETICA_OBLIQUE );
			fontFamilies.put( BaseFont.HELVETICA.toLowerCase(), tmp );
			
			// times
			tmp = new Vector.<String>();
			tmp.push( BaseFont.TIMES_BOLD );
			tmp.push( BaseFont.TIMES_BOLDITALIC );
			tmp.push( BaseFont.TIMES_ITALIC );
			tmp.push( BaseFont.TIMES_ROMAN );
			fontFamilies.put( "times", tmp );
			fontFamilies.put( BaseFont.TIMES_ROMAN.toLowerCase(), tmp );
			
			// symbol
			tmp = new Vector.<String>();
			tmp.push( BaseFont.SYMBOL );
			fontFamilies.put( BaseFont.SYMBOL.toLowerCase(), tmp );
			
			// z
			tmp = new Vector.<String>();
			tmp.push( BaseFont.ZAPFDINGBATS );
			fontFamilies.put( BaseFont.ZAPFDINGBATS.toLowerCase(), tmp );
			
		}
		
		public function isRegistered(fontname:String):Boolean
		{
			return trueTypeFonts.containsKey( fontname.toLowerCase() );
		}
		
		public function getFont(fontname:String, encoding:String, embedded:Boolean, size:Number, style:int, color:RGBColor):Font
		{
			return getFont1( fontname, encoding, embedded, size, style, color, true );
		}
		
		public function getFont1( fontname: String, encoding: String, embedded: Boolean, size: Number, style: int, color: RGBColor, cached: Boolean = true ): Font
		{
			if( fontname == null ) return new Font( Font.UNDEFINED, size, style, color );
			var lowercasefontname: String = fontname.toLowerCase();
			var tmp: Vector.<String> = fontFamilies.getValue( lowercasefontname ) as Vector.<String>;
			
			if( tmp != null )
			{
				var s: int = style == Font.UNDEFINED ? Font.NORMAL : style;
				var fs: int = Font.NORMAL;
				var found: Boolean = false;
				
				for( var k: int = 0; k < tmp.length; ++k )
				{
					var f: String = tmp[k];
					var lcf: String = f.toLowerCase();
					fs = Font.NORMAL;
					if( lcf.toLowerCase().indexOf("bold") != -1) fs |= Font.BOLD;
					if( lcf.toLowerCase().indexOf("italic") != -1 || lcf.toLowerCase().indexOf("oblique") != -1) fs |= Font.ITALIC;
					if( (s & Font.BOLDITALIC) == fs )
					{
						fontname = f;
						found = true;
						break;
					}
				}
				
				if( style != Font.UNDEFINED && found )
				{
					style &= ~fs;
				}
			}
			
			var basefont: BaseFont = null;
			
			try {
				try {
					// the font is a type 1 font or CJK font
					basefont = BaseFont.createFont( fontname, encoding, embedded, cached, null, null, true );
				}
				catch(de: DocumentError) {
				}
				
				if (basefont == null) {
					fontname = trueTypeFonts.getProperty(fontname.toLowerCase());
					if (fontname == null) return new Font(Font.UNDEFINED, size, style, color);
					basefont = BaseFont.createFont(fontname, encoding, embedded, cached, null, null);
				}
			}
			catch( de: DocumentError) {
				throw new ConversionError(de);
			}
			catch( npe: Error ) {
				// null was entered as fontname and/or encoding
				return new Font(Font.UNDEFINED, size, style, color);
			}
			return new Font( Font.UNDEFINED, size, style, color, basefont );
		}
	}
}