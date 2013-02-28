/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: BaseFont.as 240 2010-02-01 10:53:22Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 240 $ $LastChangedDate: 2010-02-01 05:53:22 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/BaseFont.as $
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
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.ByteBuffer;
	import org.purepdf.pdf.PdfEncodings;
	import org.purepdf.pdf.PdfIndirectReference;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfStream;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.StringUtils;

	[Abstract]
	public class BaseFont extends ObjectHash
	{
		public static const ASCENT: int = 1;
		public static const AWT_ASCENT: int = 9;
		public static const AWT_DESCENT: int = 10;
		public static const AWT_LEADING: int = 11;
		public static const AWT_MAXADVANCE: int = 12;
		public static const BBOXLLX: int = 5;
		public static const BBOXLLY: int = 6;
		public static const BBOXURX: int = 7;
		public static const BBOXURY: int = 8;
		public static const CACHED: Boolean = true;
		public static const CAPHEIGHT: int = 2;
		public static const CHAR_RANGE_ARABIC: Vector.<int> = Vector.<int>( [ 0, 0x7f, 0x0600, 0x067f, 0x20a0, 0x20cf, 0xfb50, 0xfbff, 0xfe70, 0xfeff ] );
		public static const CHAR_RANGE_CYRILLIC: Vector.<int> = Vector.<int>( [ 0, 0x7f, 0x0400, 0x052f, 0x2000, 0x206f, 0x20a0, 0x20cf ] );
		public static const CHAR_RANGE_HEBREW: Vector.<int> = Vector.<int>( [ 0, 0x7f, 0x0590, 0x05ff, 0x20a0, 0x20cf, 0xfb1d, 0xfb4f ] );

		public static const CHAR_RANGE_LATIN: Vector.<int> = Vector.<int>( [ 0, 0x17f, 0x2000, 0x206f, 0x20a0, 0x20cf, 0xfb00, 0xfb06 ] );
		public static const CID_NEWLINE: String = '\U7fff';
		public static const COURIER: String = "Courier.afm";
		public static const COURIER_BOLD: String = "Courier-Bold.afm";
		public static const COURIER_BOLDOBLIQUE: String = "Courier-BoldOblique.afm";
		public static const COURIER_OBLIQUE: String = "Courier-Oblique.afm";

		public static const CP1250: String = "Cp1250";
		public static const CP1252: String = "Cp1252";
		public static const CP1257: String = "Cp1257";
		public static const AdobeCNS1_UCS2: String = "Adobe-CNS1-UCS2";
		public static const AdobeGB1_UCS2: String = "Adobe-GB1-UCS2";
		public static const AdobeJapan1_UCS2: String = "Adobe-Japan1-UCS2";
		public static const AdobeKorea1_UCS2: String = "Adobe-Korea1-UCS2";
		public static const UniCNS_UCS2_H: String = "UniCNS-UCS2-H";
		public static const UniCNS_UCS2_V: String = "UniCNS-UCS2-V";
		public static const UniGB_UCS2_H: String = "UniGB-UCS2-H";
		public static const UniGB_UCS2_V: String = "UniGB-UCS2-V";
		public static const UniJIS_UCS2_H: String = "UniJIS-UCS2-H";
		public static const UniJIS_UCS2_HW_H: String = "UniJIS-UCS2-HW-H";
		public static const UniJIS_UCS2_HW_V: String = "UniJIS-UCS2-HW-V";
		public static const UniJIS_UCS2_V: String = "UniJIS-UCS2-V";
		public static const UniKS_UCS2_H: String = "UniKS-UCS2-H";
		public static const UniKS_UCS2_V: String = "UniKS-UCS2-V";
		public static const DESCENT: int = 3;

		public static const EMBEDDED: Boolean = true;
		public static const FONT_TYPE_CJK: int = 2;
		public static const FONT_TYPE_DOCUMENT: int = 4;
		public static const FONT_TYPE_T1: int = 0;
		public static const FONT_TYPE_T3: int = 5;
		public static const FONT_TYPE_TT: int = 1;
		public static const FONT_TYPE_TTUNI: int = 3;
		public static const HELVETICA: String = "Helvetica.afm";
		public static const HELVETICA_BOLD: String = "Helvetica-Bold.afm";
		public static const HELVETICA_BOLDOBLIQUE: String = "Helvetica-BoldOblique.afm";
		public static const HELVETICA_OBLIQUE: String = "Helvetica-Oblique.afm";
		public static const IDENTITY_H: String = "Identity-H";
		public static const IDENTITY_V: String = "Identity-V";
		public static const ITALICANGLE: int = 4;
		public static const MACROMAN: String = "MacRoman";
		public static const NOT_CACHED: Boolean = false;
		public static const NOT_EMBEDDED: Boolean = false;
		public static const RESOURCE_PATH: String = "fonts/";
		public static const STRIKETHROUGH_POSITION: int = 15;
		public static const STRIKETHROUGH_THICKNESS: int = 16;
		public static const SUBSCRIPT_OFFSET: int = 18;
		public static const SUBSCRIPT_SIZE: int = 17;
		public static const SUPERSCRIPT_OFFSET: int = 20;
		public static const SUPERSCRIPT_SIZE: int = 19;
		public static const SYMBOL: String = "Symbol.afm";
		public static const TIMES_BOLD: String = "Times-Bold.afm";
		public static const TIMES_BOLDITALIC: String = "Times-BoldItalic.afm";
		public static const TIMES_ITALIC: String = "Times-Italic.afm";
		public static const TIMES_ROMAN: String = "Times-Roman.afm";
		public static const UNDERLINE_POSITION: int = 13;
		public static const UNDERLINE_THICKNESS: int = 14;
		public static const WINANSI: String = "Cp1252";
		public static const ZAPFDINGBATS: String = "ZapfDingbats.afm";
		public static const notdef: String = ".notdef";
		protected static var _builtinFonts14: HashMap;
		protected static var fontCache: HashMap = new HashMap();

		protected var _compressionLevel: int = PdfStream.BEST_COMPRESSION;
		protected var _encoding: String;
		protected var _fontType: int;
		protected var charBBoxes: Vector.<Vector.<int>> = new Vector.<Vector.<int>>( 256 );
		protected var differences: Vector.<String> = new Vector.<String>( 256 );
		protected var directTextToByte: Boolean = false;
		protected var embedded: Boolean;
		protected var fastWinansi: Boolean = false;
		protected var _fontSpecific: Boolean = true;
		protected var forceWidthsOutput: Boolean = false;

		protected var specialMap: Object;
		protected var _subset: Boolean = true;
		protected var subsetRanges: Vector.<Vector.<int>>;
		protected var unicodeDifferences: Vector.<int> = new Vector.<int>( 256 );
		protected var widths: Vector.<int> = new Vector.<int>( 256 );

		public function BaseFont()
		{
			super();
		}
		
		public function getUnicodeDifferences( index: int ): int
		{
			return unicodeDifferences[index];
		}

		public function get fontSpecific():Boolean
		{
			return _fontSpecific;
		}

		public function set fontSpecific(value:Boolean):void
		{
			_fontSpecific = value;
		}

		public function get subset():Boolean
		{
			return _subset;
		}

		public function set subset(value:Boolean):void
		{
			_subset = value;
		}

		public function addSubsetTange( range: Vector.<int> ): void
		{
			if ( subsetRanges == null )
				subsetRanges = new Vector.<Vector.<int>>();
			subsetRanges.push( range );
		}

		public function get compressionLevel(): int
		{
			return _compressionLevel;
		}

		public function set compressionLevel( value: int ): void
		{
			if ( value < PdfStream.NO_COMPRESSION || value > PdfStream.BEST_COMPRESSION )
				_compressionLevel = PdfStream.NO_COMPRESSION;
			_compressionLevel = value;
		}

		public function get encoding(): String
		{
			return _encoding;
		}

		public function get fontType(): int
		{
			return _fontType;
		}
		
		public function charExists( c: int ): Boolean
		{
			var b: Bytes = convertToByte(c);
			return b.length > 0;
		}

		[Abstract]
		public function getFamilyFontName(): Vector.<Vector.<String>>
		{
			throw new NonImplementatioError();
		}
		
		[Abstract]
		public function getPostscriptFontName(): String
		{
			throw new NonImplementatioError();
		}

		[Abstract]
		public function getFontDescriptor( key: int, fontSize: Number ): Number
		{
			throw new NonImplementatioError();
		}

		/**
		 * Gets the kerning between two Unicode chars
		 */
		[Abstract]
		public function getKerning( char1: int, char2: int ): int
		{
			throw new NonImplementatioError();
		}

		public function getUnicodeEquivalent( c: int ): int
		{
			return c;
		}
		
		[Abstract]
		public function setKerning( char1: int, char2: int, kern: int ): Boolean
		{
			throw new NonImplementatioError();
		}

		/**
		 * Gets the width of a char in normalized 1000 units
		 * Possible input parameters are: String,int
		 * @param code. Allowed values are int, String
		 */
		public function getWidth( code: Object ): int
		{
			if ( code is String )
				return _getWidthS( String( code ) );
			else if ( code is Number )
				return _getWidthI( int( code ) );

			throw new ArgumentError( "Allowed parameter are only int and String" );
		}

		/**
		 * Gets the width of a char in points.
		 *
		 * @param code. Allowed values are int, String
		 */
		public function getWidthPoint( code: Object, fontSize: Number ): Number
		{
			return getWidth( code ) * 0.001 * fontSize;
		}

		/**
		 * Gets the width of a string in points taking kerning
		 * into account
		 */
		public function getWidthPointKerned( text: String, fontSize: Number ): Number
		{
			var size: Number = getWidth( text ) * 0.001 * fontSize;

			if ( !hasKernPairs() )
				return size;

			var len: int = text.length - 1;
			var kern: int = 0;
			var c: Vector.<int> = StringUtils.toCharArray( text );

			for ( var k: int = 0; k < len; ++k )
				kern += getKerning( c[ k ], c[ k + 1 ] );

			return size + kern * 0.001 * fontSize;
		}

		/**
		 * Checks if the font has any kerning pairs
		 */
		[Abstract]
		public function hasKernPairs(): Boolean
		{
			throw new NonImplementatioError();
		}

		[Abstract]
		protected function getRawCharBBox( c: int, name: String ): Vector.<int>
		{
			throw new NonImplementatioError();
		}

		[Abstract]
		public function getCharBBox( c: int ): Vector.<int> {
			throw new NonImplementatioError();
		}
		
		/**
		 * Gets the width from the font according to the Unicode char c
		 * or the name
		 */
		[Abstract]
		protected function getRawWidth( c: int, name: String ): int
		{
			throw new NonImplementatioError();
		}

		/**
		 * Converts a char to a Bytes according to the font's encoding.
		 */
		internal function convertToBytes( char1: String ): Bytes
		{
			var code: int = char1.charCodeAt( 0 );

			if ( directTextToByte )
				return PdfEncodings.convertToBytes( char1, null );

			if ( specialMap != null )
				if ( specialMap[ code ] )
					return new Bytes( [ specialMap[ code ] ] );
				else
					return new Bytes();

			return PdfEncodings.convertToBytes( char1, _encoding );
		}
		
		/**
		 * Converts a char to a Bytes according to the font's encoding.
		 */
		internal function convertToByte( char1: int ): Bytes
		{
			var code: int = char1;
			
			if ( directTextToByte )
				return PdfEncodings.convertToByte( char1, null );
			
			if ( specialMap != null )
				if ( specialMap[ code ] )
					return new Bytes( [ specialMap[ code ] ] );
				else
					return new Bytes();
			
			return PdfEncodings.convertToByte( char1, _encoding );
		}

		/**
		 * @throws IOError
		 * @throws DocumentError;
		 */
		[Abstract]
		internal function getFullFontStream(): PdfStream
		{
			throw new NonImplementatioError();
		}

		/**
		 * @throws DocumentError
		 * @throws IOError
		 */
		[Abstract]
		internal function writeFont( writer: PdfWriter, ref: PdfIndirectReference, params: Vector.<Object> ): void
		{
			throw new NonImplementatioError();
		}

		protected function _getWidthI( code: int ): int
		{
			if ( fastWinansi )
			{
				if ( code < 128 || ( code >= 160 && code <= 255 ) )
					return widths[ code ];
				else
					return widths[ PdfEncodings.winansi[ code ] ];
			}
			else
			{
				var total: int = 0;
				var mbytes: Bytes = convertToBytes( String.fromCharCode( code ) );

				for ( var k: int = 0; k < mbytes.length; ++k )
					total += widths[ 0xff & mbytes[ k ] ];
				return total;
			}
		}

		protected function _getWidthS( text: String ): int
		{
			var total: int = 0;
			var k: int;

			if ( fastWinansi )
			{
				var len: int = text.length;

				for ( k = 0; k < len; ++k )
				{
					var char1: int = text.charCodeAt( k );

					if ( char1 < 128 || ( char1 >= 160 && char1 <= 255 ) )
						total += widths[ char1 ];
					else
						total += widths[ PdfEncodings.winansi[ char1 ] ];
				}
				return total;
			}
			else
			{
				var mbytes: Bytes = convertToBytes( text );

				for ( k = 0; k < mbytes.length; ++k )
					total += widths[ 0xff & mbytes[ k ] ];
			}
			return total;
		}

		public static function get builtinFonts14(): HashMap
		{
			if ( _builtinFonts14 == null )
				init_builtinFonts14();
			return _builtinFonts14;
		}

		/**
		 * Creates a new font. This font can be one of the 14 built in types,
		 * a Type1 font referred to by an AFM or PFM file, a TrueType font (simple or collection) or a CJK font from the
		 * Adobe Asian Font Pack. TrueType fonts and CJK fonts can have an optional style modifier
		 * appended to the name. These modifiers are: Bold, Italic and BoldItalic. An
		 * example would be "STSong-Light,Bold". Note that this modifiers do not work if
		 * the font is embedded. Fonts in TrueType collections are addressed by index such as "msgothic.ttc,1".
		 * This would get the second font (indexes start at 0), in this case "MS PGothic".
		 *
		 * @throws DocumentError
		 * @throws IOError
		 */
		public static function createFont( name: String, encoding: String, embedded: Boolean=NOT_EMBEDDED, cached: Boolean=CACHED, ttfAfm: Vector
			.<int>=null, pfb: Vector.<int>=null, noThrow: Boolean=false, forceRead: Boolean=false ): BaseFont
		{
			//trace( "BaseFont.createFont. To be implemented" );

			var nameBase: String = getBaseName( name );
			encoding = normalizeEncoding( encoding );
			var is_builtinFonts14: Boolean = builtinFonts14.containsKey( name );
			var isCJKFont: Boolean = is_builtinFonts14 ? false : CJKFont.isCJKFont( nameBase, encoding );

			if ( is_builtinFonts14 || isCJKFont )
				embedded = false;
			else if ( encoding == IDENTITY_H || encoding == IDENTITY_V )
				embedded = true;

			var fontFound: BaseFont = null;
			var fontBuilt: BaseFont = null;
			var key: String = name + "\n" + encoding + "\n" + embedded;

			if ( cached )
			{
				fontFound = fontCache.getValue( key ) as BaseFont;

				if ( fontFound != null )
					return fontFound;
			}

			if ( is_builtinFonts14 || StringUtils.endsWith( name, ".afm" ) || StringUtils.endsWith( name, ".pfm" ) )
			{
				fontBuilt = new Type1Font( name, encoding, embedded, ttfAfm, pfb, forceRead );
				fontBuilt.fastWinansi = encoding == CP1252;
			}
			else if ( StringUtils.endsWith( nameBase, ".ttf" ) || StringUtils.endsWith( nameBase, ".otf" ) || nameBase.toLowerCase()
				.indexOf( ".ttc," ) > 0 )
			{
				if( encoding == IDENTITY_H || encoding == IDENTITY_V)
				{
					fontBuilt = new TrueTypeFontUnicode();
					TrueTypeFontUnicode(fontBuilt).init( name, encoding, embedded, ttfAfm, false, forceRead );
				} else {
					fontBuilt = new TrueTypeFont();
					TrueTypeFont(fontBuilt).init( name, encoding, embedded, ttfAfm, false, forceRead );
					TrueTypeFont(fontBuilt).fastWinansi = encoding == CP1252;
				}
			}
			else if ( isCJKFont )
			{
				fontBuilt = new CJKFont();
				CJKFont(fontBuilt).init( name, encoding, embedded );
			}
			else if ( noThrow )
				return null;
			else
				throw new DocumentError( "font " + name + " with " + encoding + " is not recognized" );

			if ( cached )
			{
				fontFound = fontCache.getValue( key ) as BaseFont;

				if ( fontFound != null )
					return fontFound;
				fontCache.put( key, fontBuilt );
			}
			return fontBuilt;
		}
		
		
		
		protected function createEncoding(): void
		{
			var k: int;
			
			if ( StringUtils.startsWith( encoding, "#" ) )
			{
				throw new NonImplementatioError();
			}
			else if ( _fontSpecific )
			{
				for ( k = 0; k < 256; ++k )
				{
					widths[ k ] = getRawWidth( k, null );
					charBBoxes[ k ] = getRawCharBBox( k, null );
				}
			}
			else
			{
				var s: String;
				var name: String;
				var c: int;
				var b: Bytes = new Bytes( 1 );
				
				for ( k = 0; k < 256; ++k )
				{
					b[ 0 ] = ByteBuffer.intToByte( k );
					s = PdfEncodings.convertToString( b, encoding );
					
					if ( s.length > 0 )
						c = s.charCodeAt( 0 );
					else
						c = 63; // '?'
					
					name = GlyphList.unicode2name( c );
					
					if ( name == null )
						name = notdef;
					
					differences[ k ] = name;
					unicodeDifferences[ k ] = c;
					widths[ k ] = getRawWidth( c, name );
					charBBoxes[ k ] = getRawCharBBox( c, name );
				}
			}
		}
		
		/** Creates a unique subset prefix to be added to the font name when the font is embedded and subset.
		 * @return the subset prefix
		 */
		public static function createSubsetPrefix(): String
		{
			var s: String = "";
			for( var k: int = 0; k < 6; ++k )
				s += String.fromCharCode( int( Math.random() * 26 ) + 65 );
			return s + "+";
		}


		/**
		 * Gets the fontname without the modifiers Bold, Italic or BoldItalic.
		 */
		protected static function getBaseName( name: String ): String
		{
			return name;
			if ( StringUtils.endsWith( name, ",Bold" ) )
				return name.substring( 0, name.length - 5 );
			else if ( StringUtils.endsWith( name, ",Italic" ) )
				return name.substring( 0, name.length - 7 );
			else if ( StringUtils.endsWith( name, ",BoldItalic" ) )
				return name.substring( 0, name.length - 11 );
			else
				return name;
		}

		/**
		 * Normalize the encoding name
		 */
		protected static function normalizeEncoding( enc: String ): String
		{
			if ( enc == "winansi" || enc == "" )
				return CP1252;

			else if ( enc == "macroman" )
				return MACROMAN;
			else
				return enc;
		}

		private static function init_builtinFonts14(): void
		{
			_builtinFonts14 = new HashMap();
			_builtinFonts14.put( COURIER, PdfName.COURIER );
			_builtinFonts14.put( COURIER_BOLD, PdfName.COURIER_BOLD );
			_builtinFonts14.put( COURIER_BOLDOBLIQUE, PdfName.COURIER_BOLDOBLIQUE );
			_builtinFonts14.put( COURIER_OBLIQUE, PdfName.COURIER_OBLIQUE );
			_builtinFonts14.put( HELVETICA, PdfName.HELVETICA );
			_builtinFonts14.put( HELVETICA_BOLD, PdfName.HELVETICA_BOLD );
			_builtinFonts14.put( HELVETICA_BOLDOBLIQUE, PdfName.HELVETICA_BOLDOBLIQUE );
			_builtinFonts14.put( HELVETICA_OBLIQUE, PdfName.HELVETICA_OBLIQUE );
			_builtinFonts14.put( SYMBOL, PdfName.SYMBOL );
			_builtinFonts14.put( TIMES_ROMAN, PdfName.TIMES_ROMAN );
			_builtinFonts14.put( TIMES_BOLD, PdfName.TIMES_BOLD );
			_builtinFonts14.put( TIMES_BOLDITALIC, PdfName.TIMES_BOLDITALIC );
			_builtinFonts14.put( TIMES_ITALIC, PdfName.TIMES_ITALIC );
			_builtinFonts14.put( ZAPFDINGBATS, PdfName.ZAPFDINGBATS );
		}
	}
}