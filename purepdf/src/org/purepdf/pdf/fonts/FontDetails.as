/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: FontDetails.as 239 2010-01-31 23:23:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 239 $ $LastChangedDate: 2010-01-31 18:23:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/FontDetails.as $
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
	import flash.utils.Endian;
	
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.IntHashMap;
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.errors.ConversionError;
	import org.purepdf.pdf.PdfEncodings;
	import org.purepdf.pdf.PdfIndirectReference;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.Utilities;
	import org.purepdf.utils.pdf_core;

	[ExcludeClass]
	public class FontDetails extends ObjectHash
	{
		protected var _subset: Boolean = true;
		private var _baseFont: BaseFont;
		private var _cjkTag: IntHashMap;
		private var _cjkFont: CJKFont;
		private var _fontName: PdfName;
		private var _fontType: int;
		private var _indirectReference: PdfIndirectReference;
		private var _longTag: HashMap;
		private var _shortTag: Vector.<int>;
		private var _symbolic: Boolean;
		private var _ttu: TrueTypeFontUnicode;

		/**
		 * Each font used in a document has an instance of this class.
		 * This class stores the characters used in the document and other
		 * specifics unique to the current working document.
		 */
		public function FontDetails( $fontName: PdfName, $indirectReference: PdfIndirectReference, $baseFont: BaseFont )
		{
			_fontName = $fontName;
			_indirectReference = $indirectReference;
			_baseFont = $baseFont;
			_fontType = $baseFont.fontType;

			switch ( _fontType )
			{
				case BaseFont.FONT_TYPE_T1:
				case BaseFont.FONT_TYPE_TT:
					_shortTag = new Vector.<int>( 256 );
					break;
				
				case BaseFont.FONT_TYPE_CJK:
					_cjkTag = new IntHashMap( 1000 );
					_cjkFont = baseFont as CJKFont;
					break;
				
				case BaseFont.FONT_TYPE_TTUNI:
					_longTag = new HashMap();
					_ttu = baseFont as TrueTypeFontUnicode;
					_symbolic = baseFont.fontSpecific;
					break;
			}
		}
		
		/**
		 * Convert a string into <code>Bytes</code> to be placed in the document.
		 * The conversion is done according to the font and the encoding and the characters
		 * used are stored.
		 * 
		 * @see org.purepdf.utils.Bytes
		 */
		pdf_core function convertToBytes( text: String ): Bytes
		{
			var b: Bytes = null;
			var len: int;
			var k: int;
			
			switch( _fontType )
			{
				case BaseFont.FONT_TYPE_T3:
					return baseFont.convertToBytes( text );
					
				case BaseFont.FONT_TYPE_T1:
				case BaseFont.FONT_TYPE_TT:
					b = baseFont.convertToBytes(text);
					len = b.length;
					for( k = 0; k < len; ++k )
						_shortTag[ b[k] & 0xff ] = 1;
					break;
				
				case BaseFont.FONT_TYPE_CJK:
					len = text.length;
					for( k = 0; k < len; ++k )
						_cjkTag.put( _cjkFont.getCidCode( text.charCodeAt(k) ), 0 );
					b = baseFont.convertToBytes( text );
					break;
				
				case BaseFont.FONT_TYPE_DOCUMENT:
					b = baseFont.convertToBytes( text );
					break;
				
				case BaseFont.FONT_TYPE_TTUNI:
					len = text.length;
					var metrics: Vector.<int> = null;
					var glyph: String = "";
					var glyphs: Vector.<int> = new Vector.<int>();
					var i: int = 0;
					
					var tmp: ByteArray = new ByteArray();
					tmp.endian = Endian.LITTLE_ENDIAN;
					
					if( symbolic )
					{
						b = PdfEncodings.convertToBytes(text, "symboltt");
						len = b.length;
						for ( k = 0; k < len; ++k )
						{
							metrics = _ttu.getMetricsTT(b[k] & 0xff);
							if (metrics == null)
								continue;
							_longTag.put( metrics[0], Vector.<int>([ metrics[0], metrics[1], _ttu.getUnicodeDifferences(b[k] & 0xff)]) );
							glyph += String.fromCharCode( metrics[0] );
							tmp.writeMultiByte( String.fromCharCode( metrics[0] ), "unicodeFFFE" );
						}
					} else 
					{
						for(  k = 0; k < len; ++k )
						{
							var val: int;
							if( Utilities.isSurrogatePair2(text, k) )
							{
								val = Utilities.convertToUtf32_2(text, k);
								k++;
							} else 
							{
								val = text.charCodeAt(k);
							}
							metrics = _ttu.getMetricsTT(val);
							
							if (metrics == null)
								continue;
							
							var m0: int = metrics[0];
							var gl: int = m0;
							if( !_longTag.containsKey(gl) )
								_longTag.put(gl, Vector.<int>([m0, metrics[1], val]) );
							glyph += String.fromCharCode( m0 );
							tmp.writeMultiByte( String.fromCharCode( m0 ), "unicodeFFFE" );
						}
					}
					
					//b = new Bytes();
					//b.buffer.writeMultiByte( glyph, "unicodeFFFE" );
					
					b = new Bytes();
					b.buffer = tmp;
					
					return b;
					break;
			}
			return b;
		}
		
		/**
		 * Write the font definition to the document
		 * @see PdfWriter
		 */
		pdf_core function writeFont( writer: PdfWriter ): void
		{
			try
			{
				switch( _fontType )
				{
					case BaseFont.FONT_TYPE_T3:
						baseFont.writeFont( writer, indirectReference, null );
						break;
					
					case BaseFont.FONT_TYPE_T1:
					case BaseFont.FONT_TYPE_TT:
						var firstChar: int;
						var lastChar: int;
						for( firstChar = 0; firstChar < 256; ++firstChar )
						{
							if( _shortTag[firstChar] != 0 )
								break;
						}
						
						for( lastChar = 255; lastChar >= firstChar; --lastChar )
						{
							if( _shortTag[lastChar] != 0 )
								break;
						}
						
						if( firstChar > 255 )
						{
							firstChar = 255;
							lastChar = 255;
						}
						
						baseFont.writeFont( writer, indirectReference, Vector.<Object>([firstChar, lastChar, _shortTag, subset ]) );
						break;
					
					case BaseFont.FONT_TYPE_CJK:
						baseFont.writeFont( writer, indirectReference, Vector.<Object>([_cjkTag]) );
						break;
					
					case BaseFont.FONT_TYPE_TTUNI:
						baseFont.writeFont( writer, indirectReference, Vector.<Object>([_longTag, subset]) );
						break;
				}
			} catch( e: Error ) 
			{
				trace( e.getStackTrace() );
				throw new ConversionError( e );
			}
		}

		public function get baseFont(): BaseFont
		{
			return _baseFont;
		}

		public function get fontName(): PdfName
		{
			return _fontName;
		}

		public function get fontType(): int
		{
			return _fontType;
		}

		public function get indirectReference(): PdfIndirectReference
		{
			return _indirectReference;
		}

		/**
		 * Indicates if all the glyphs and widths for that particular
		 * encoding should be included in the document.
		 * @return false to include all the glyphs and widths.
		 */
		public function get subset(): Boolean
		{
			return _subset;
		}

		public function set subset( value: Boolean ): void
		{
			_subset = value;
		}

		public function get symbolic(): Boolean
		{
			return _symbolic;
		}
	}
}