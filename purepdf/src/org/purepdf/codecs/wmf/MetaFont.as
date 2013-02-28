/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: MetaFont.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
 * $Author Alessandro Crugnola $
 * $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/codecs/wmf/MetaFont.as $
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
package org.purepdf.codecs.wmf
{
	import org.purepdf.Font;
	import org.purepdf.elements.Meta;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.factories.FontFactory;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.Bytes;

	public class MetaFont extends MetaObject
	{
		public static const BOLDTHRESHOLD: int = 600;

		public static const DEFAULT_PITCH: int = 0;
		public static const ETO_CLIPPED: int = 4;
		public static const ETO_OPAQUE: int = 2;
		public static const FF_DECORATIVE: int = 5;
		public static const FF_DONTCARE: int = 0;
		public static const FF_MODERN: int = 3;
		public static const FF_ROMAN: int = 1;
		public static const FF_SCRIPT: int = 4;
		public static const FF_SWISS: int = 2;
		public static const FIXED_PITCH: int = 1;
		public static const MARKER_BOLD: int = 1;
		public static const MARKER_COURIER: int = 0;
		public static const MARKER_HELVETICA: int = 4;
		public static const MARKER_ITALIC: int = 2;
		public static const MARKER_SYMBOL: int = 12;
		public static const MARKER_TIMES: int = 8;
		public static const VARIABLE_PITCH: int = 2;
		
		public static const fontNames: Vector.<String> = Vector.<String>( [ "Courier", "Courier-Bold", "Courier-Oblique", "Courier-BoldOblique", "Helvetica",
				"Helvetica-Bold", "Helvetica-Oblique", "Helvetica-BoldOblique", "Times-Roman", "Times-Bold", "Times-Italic", "Times-BoldItalic", "Symbol",
				"ZapfDingbats" ] );
		
		public static const nameSize: int = 32;

		public var angle: Number;
		public var bold: int;
		public var charset: int;
		public var faceName: String = "arial";
		public var height: int;
		public var italic: int;
		public var pitchAndFamily: int;
		public var strikeout: Boolean;
		public var underline: Boolean;
		protected var font: BaseFont = null;

		public function MetaFont()
		{
			_type = META_FONT;
		}

		public function getFont(): BaseFont
		{
			if ( font != null )
				return font;
			var ff2: Font = FontFactory.getFont( faceName, BaseFont.CP1252, true, 10, ( ( italic != 0 ) ? Font.ITALIC : 0 ) | ( ( bold != 0 ) ? Font.BOLD :
					0 ) );
			font = ff2.baseFont;
			if ( font != null )
				return font;
			var fontName: String;
			if ( faceName.indexOf( "courier" ) != -1 || faceName.indexOf( "terminal" ) != -1 || faceName.indexOf( "fixedsys" ) != -1 )
			{
				fontName = fontNames[MARKER_COURIER + italic + bold];
			} else if ( faceName.indexOf( "ms sans serif" ) != -1 || faceName.indexOf( "arial" ) != -1 || faceName.indexOf( "system" ) != -1 )
			{
				fontName = fontNames[MARKER_HELVETICA + italic + bold];
			} else if ( faceName.indexOf( "arial black" ) != -1 )
			{
				fontName = fontNames[MARKER_HELVETICA + italic + MARKER_BOLD];
			} else if ( faceName.indexOf( "times" ) != -1 || faceName.indexOf( "ms serif" ) != -1 || faceName.indexOf( "roman" ) != -1 )
			{
				fontName = fontNames[MARKER_TIMES + italic + bold];
			} else if ( faceName.indexOf( "symbol" ) != -1 )
			{
				fontName = fontNames[MARKER_SYMBOL];
			} else
			{
				var pitch: int = pitchAndFamily & 3;
				var family: int = ( pitchAndFamily >> 4 ) & 7;
				switch ( family )
				{
					case FF_MODERN:
						fontName = fontNames[MARKER_COURIER + italic + bold];
						break;
					case FF_ROMAN:
						fontName = fontNames[MARKER_TIMES + italic + bold];
						break;
					case FF_SWISS:
					case FF_SCRIPT:
					case FF_DECORATIVE:
						fontName = fontNames[MARKER_HELVETICA + italic + bold];
						break;
					default:
					{
						switch ( pitch )
						{
							case FIXED_PITCH:
								fontName = fontNames[MARKER_COURIER + italic + bold];
								break;
							default:
								fontName = fontNames[MARKER_HELVETICA + italic + bold];
								break;
						}
					}
				}
			}
			try
			{
				font = BaseFont.createFont( fontName, "Cp1252", false );
			} catch ( e: Error )
			{
				throw new ConversionError( e );
			}
			return font;
		}

		public function getFontSize( state: MetaState ): Number
		{
			return Math.abs( state.transformY( height ) - state.transformY( 0 ) ) * PdfDocument.wmfFontCorrection;
		}

		public function init( input: InputMeta ): void
		{
			height = Math.abs( input.readShort() );
			input.skip( 2 );
			angle = Number( input.readShort() / 1800.0 * Math.PI );
			input.skip( 2 );
			bold = ( input.readShort() >= BOLDTHRESHOLD ? MARKER_BOLD : 0 );
			italic = ( input.readByte() != 0 ? MARKER_ITALIC : 0 );
			underline = ( input.readByte() != 0 );
			strikeout = ( input.readByte() != 0 );
			charset = input.readByte();
			input.skip( 3 );
			pitchAndFamily = input.readByte();
			var name: Bytes = new Bytes( nameSize );
			var k: int;
			for ( k = 0; k < nameSize; ++k )
			{
				var c: int = input.readByte();
				if ( c == 0 )
				{
					break;
				}
				name[k] = c;
			}
			faceName = name.readAsString( 0, k );
			faceName = faceName.toLowerCase();
		}
	}
}