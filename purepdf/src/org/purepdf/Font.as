/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Font.as 249 2010-02-02 06:59:26Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 249 $ $LastChangedDate: 2010-02-02 01:59:26 -0500 (Tue, 02 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/Font.as $
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
	import org.purepdf.colors.RGBColor;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.factories.FontFactory;
	import org.purepdf.html.Markup;
	import org.purepdf.pdf.fonts.BaseFont;

	public class Font implements IComparable, IClonable
	{
		public static const BOLD: int = 1;
		public static const BOLDITALIC: int = BOLD | ITALIC;
		public static const COURIER: int = 0;
		public static const DEFAULTSIZE: int = 12;
		public static const HELVETICA: int = 1;
		public static const ITALIC: int = 2;
		public static const NORMAL: int = 0;
		public static const STRIKETHRU: int = 8;
		public static const SYMBOL: int = 3;
		public static const TIMES_ROMAN: int = 2;
		public static const UNDEFINED: int = -1;
		public static const UNDERLINE: int = 4;
		public static const ZAPFDINGBATS: int = 4;
		private var _baseFont: BaseFont = null;
		private var _color: RGBColor = null;
		private var _family: int = UNDEFINED;
		private var _size: Number = UNDEFINED;
		private var _style: int = UNDEFINED;

		/**
		 *
		 * @param $style a combination of Font style ( eg: Font.UNDERLINE | Font.BOLD )
		 */
		public function Font( family: int = UNDEFINED, size: Number = DEFAULTSIZE, style: int = UNDEFINED, color: RGBColor = null,
						baseFont: BaseFont = null )
		{
			_family = family;
			_size = size;
			_style = style;
			_color = color;
			_baseFont = baseFont;

			if ( baseFont != null )
				_family = UNDEFINED;
		}

		public function get baseFont(): BaseFont
		{
			return _baseFont;
		}

		public function set baseFont( value: BaseFont ): void
		{
			_baseFont = value;

			if ( value != null )
				_family = UNDEFINED;
		}

		public function clone(): Object
		{
			return new Font( _family, _size, _style, _color, _baseFont );
		}

		public function get color(): RGBColor
		{
			return _color;
		}

		public function set color( value: RGBColor ): void
		{
			_color = value;
		}

		public function compareTo( o: Object ): int
		{
			if ( o == null )
				return -1;
			var font: Font;

			try
			{
				font = Font( o );

				if ( baseFont != null && !baseFont.equals( font.baseFont ) )
					return -2;

				if ( family != font.family )
					return 1;

				if ( size != font.size )
					return 2;

				if ( style != font.style )
					return 3;

				if ( color == null )
				{
					if ( font.color == null )
						return 0;
					return 4;
				}

				if ( font.color == null )
					return 4;

				if ( color.equals( font.color ) )
					return 0;
				return 4;
			} catch ( err: Error )
			{
				return -3;
			}
			return -3;
		}

		/**
		 * Replaces the attributes that are equal to null with the
		 * attributes of a given font.
		 */
		public function difference( font: Font ): Font
		{
			if ( font == null )
				return this;
			// size
			var dSize: Number = font.size;

			if ( dSize == UNDEFINED )
			{
				dSize = size;
			}
			// style
			var dStyle: int = UNDEFINED;
			var style1: int = style;
			var style2: int = font.style;

			if ( style1 != UNDEFINED || style2 != UNDEFINED )
			{
				if ( style1 == UNDEFINED )
					style1 = 0;

				if ( style2 == UNDEFINED )
					style2 = 0;
				dStyle = style1 | style2;
			}
			// color
			var dColor: RGBColor = font.color;

			if ( dColor == null )
			{
				dColor = color;
			}

			// family
			if ( font.baseFont != null )
				return new Font( UNDEFINED, dSize, dStyle, dColor, font.baseFont );

			if ( font.family != UNDEFINED )
				return new Font( font.family, dSize, dStyle, dColor );

			if ( baseFont != null )
			{
				if ( dStyle == style1 )
					return new Font( UNDEFINED, dSize, dStyle, dColor, baseFont );
				else
					return FontFactory.getFont( familyname, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED, dSize, dStyle, dColor );
			}
			return new Font( family, dSize, dStyle, dColor );
		}

		public function get family(): int
		{
			return _family;
		}

		public function set family( value: int ): void
		{
			_family = value;
		}

		public function set familyName( name: String ): void
		{
			_family = getFamilyIndex( name );
		}

		public function get familyname(): String
		{
			var tmp: String = "unknown";

			switch ( family )
			{
				case Font.COURIER:
					return BaseFont.COURIER;
				case Font.HELVETICA:
					return BaseFont.HELVETICA;
				case Font.TIMES_ROMAN:
					return BaseFont.TIMES_ROMAN;
				case Font.SYMBOL:
					return BaseFont.SYMBOL;
				case Font.ZAPFDINGBATS:
					return BaseFont.ZAPFDINGBATS;
				default:
					if ( baseFont != null )
					{
						var names: Vector.<Vector.<String>> = baseFont.getFamilyFontName();

						for ( var i: int = 0; i < names.length; i++ )
						{
							if ( "0" == names[i][2] )
								return names[i][3];

							if ( "1033" == names[i][2] )
								tmp = names[i][3];

							if ( "" == names[i][2] )
								tmp = names[i][3];
						}
					}
			}
			return tmp;
		}

		/**
		 * Gets the BaseFont this class represents. For the built-in
		 * fonts a <CODE>BaseFont</CODE> is calculated.
		 */
		public function getCalculatedBaseFont( specialEncoding: Boolean ): BaseFont
		{
			if ( baseFont != null )
				return baseFont;
			var s: int = style;

			if ( s == UNDEFINED )
				s = NORMAL;
			var fontName: String = BaseFont.HELVETICA;
			var encoding: String = BaseFont.WINANSI;
			var cfont: BaseFont = null;

			switch ( family )
			{
				case COURIER:
					switch ( s & BOLDITALIC )
				{
					case BOLD:
						fontName = BaseFont.COURIER_BOLD;
						break;
					case ITALIC:
						fontName = BaseFont.COURIER_OBLIQUE;
						break;
					case BOLDITALIC:
						fontName = BaseFont.COURIER_BOLDOBLIQUE;
						break;
					default:
						fontName = BaseFont.COURIER;
						break;
				}
					break;
				case TIMES_ROMAN:
					switch ( s & BOLDITALIC )
				{
					case BOLD:
						fontName = BaseFont.TIMES_BOLD;
						break;
					case ITALIC:
						fontName = BaseFont.TIMES_ITALIC;
						break;
					case BOLDITALIC:
						fontName = BaseFont.TIMES_BOLDITALIC;
						break;
					case NORMAL:
					default:
						fontName = BaseFont.TIMES_ROMAN;
						break;
				}
					break;
				case SYMBOL:
					fontName = BaseFont.SYMBOL;
					if ( specialEncoding )
						encoding = BaseFont.SYMBOL;
					break;
				case ZAPFDINGBATS:
					fontName = BaseFont.ZAPFDINGBATS;
					if ( specialEncoding )
						encoding = BaseFont.ZAPFDINGBATS;
					break;
				default:
				case Font.HELVETICA:
					switch ( s & BOLDITALIC )
				{
					case BOLD:
						fontName = BaseFont.HELVETICA_BOLD;
						break;
					case ITALIC:
						fontName = BaseFont.HELVETICA_OBLIQUE;
						break;
					case BOLDITALIC:
						fontName = BaseFont.HELVETICA_BOLDOBLIQUE;
						break;
					default:
					case NORMAL:
						fontName = BaseFont.HELVETICA;
						break;
				}
					break;
			}

			try
			{
				cfont = BaseFont.createFont( fontName, encoding, false );
			} catch ( ee: Error )
			{
				throw new ConversionError( ee.message );
			}
			return cfont;
		}

		public function getCalculatedLeading( linespacing: Number ): Number
		{
			return linespacing * getCalculatedSize();
		}

		public function getCalculatedSize(): Number
		{
			var s: Number = size;

			if ( s == UNDEFINED )
				s = DEFAULTSIZE;
			return s;
		}

		public function getCalculatedStyle(): int
		{
			var s: int = style;

			if ( s == UNDEFINED )
				s = NORMAL;

			if ( baseFont != null )
				return s;

			if ( family == SYMBOL || family == ZAPFDINGBATS )
				return s;
			else
				return s & ( ~BOLDITALIC );
		}

		public function get isBold(): Boolean
		{
			if ( style == UNDEFINED )
				return false;
			return ( style & BOLD ) == BOLD;
		}

		public function get isItalic(): Boolean
		{
			if ( style == UNDEFINED )
				return false;
			return ( style & ITALIC ) == ITALIC;
		}

		public function get isStandardFont(): Boolean
		{
			return ( family == UNDEFINED && size == UNDEFINED && style == UNDEFINED && color == null && baseFont == null );
		}

		public function get isStrikethru(): Boolean
		{
			if ( style == UNDEFINED )
				return false;
			return ( style & STRIKETHRU ) == STRIKETHRU;
		}

		public function get isUnderline(): Boolean
		{
			if ( style == UNDEFINED )
				return false;
			return ( style & UNDERLINE ) == UNDERLINE;
		}

		public function get size(): Number
		{
			return _size;
		}

		public function set size( value: Number ): void
		{
			_size = value;
		}

		public function get style(): int
		{
			return _style;
		}

		public function set style( value: int ): void
		{
			_style = value;
		}

		static public function fromBaseFont( bs: BaseFont, size: Number, style: int, color: RGBColor ): Font
		{
			return new Font( UNDEFINED, size, style, color, bs );
		}

		static public function getFamilyIndex( family: String ): int
		{
			family = family.toLowerCase();

			if ( family == BaseFont.COURIER.toLowerCase() )
				return COURIER;

			if ( family == BaseFont.HELVETICA.toLowerCase() )
				return HELVETICA;

			if ( family == BaseFont.SYMBOL.toLowerCase() )
				return SYMBOL;

			if ( family == "times" || family == BaseFont.TIMES_ROMAN.toLowerCase() )
				return TIMES_ROMAN;

			if ( family == BaseFont.ZAPFDINGBATS.toLowerCase() )
				return ZAPFDINGBATS;
			return UNDEFINED;
		}

		/**
		 * Translates a String style value into the
		 * index value is used for this style
		 */
		static public function getStyleValue( style: String ): int
		{
			var s: int = 0;

			if ( style.indexOf( Markup.CSS_VALUE_NORMAL ) != -1 )
			{
				s |= NORMAL;
			}

			if ( style.indexOf( Markup.CSS_VALUE_BOLD ) != -1 )
			{
				s |= BOLD;
			}

			if ( style.indexOf( Markup.CSS_VALUE_ITALIC ) != -1 )
			{
				s |= ITALIC;
			}

			if ( style.indexOf( Markup.CSS_VALUE_OBLIQUE ) != -1 )
			{
				s |= ITALIC;
			}

			if ( style.indexOf( Markup.CSS_VALUE_UNDERLINE ) != -1 )
			{
				s |= UNDERLINE;
			}

			if ( style.indexOf( Markup.CSS_VALUE_LINETHROUGH ) != -1 )
			{
				s |= STRIKETHRU;
			}
			return s;
		}
	}
}