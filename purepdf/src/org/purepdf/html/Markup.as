/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Markup.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/html/Markup.as $
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
package org.purepdf.html
{
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.utils.StringUtils;
	
	public class Markup extends ObjectHash
	{
		public static const HTML_TAG_BODY: String = "body";
		public static const HTML_TAG_DIV: String = "div";
		public static const HTML_TAG_LINK: String = "link";
		public static const HTML_TAG_SPAN: String = "span";
		public static const HTML_ATTR_HEIGHT: String = "height";
		public static const HTML_ATTR_HREF: String = "href";
		public static const HTML_ATTR_REL: String = "rel";
		public static const HTML_ATTR_STYLE: String = "style";
		public static const HTML_ATTR_TYPE: String = "type";
		public static const HTML_ATTR_STYLESHEET: String = "stylesheet";
		public static const HTML_ATTR_WIDTH: String = "width";
		public static const HTML_ATTR_CSS_CLASS: String = "class";
		public static const HTML_ATTR_CSS_ID: String = "id";
		public static const HTML_VALUE_JAVASCRIPT: String = "text/javascript";
		public static const HTML_VALUE_CSS: String = "text/css";
		public static const CSS_KEY_BGCOLOR: String = "background-color";
		public static const CSS_KEY_COLOR: String = "color";
		public static const CSS_KEY_DISPLAY: String = "display";
		public static const CSS_KEY_FONTFAMILY: String = "font-family";
		public static const CSS_KEY_FONTSIZE: String = "font-size";
		public static const CSS_KEY_FONTSTYLE: String = "font-style";
		public static const CSS_KEY_FONTWEIGHT: String = "font-weight";
		public static const CSS_KEY_LINEHEIGHT: String = "line-height";
		public static const CSS_KEY_MARGIN: String = "margin";
		public static const CSS_KEY_MARGINLEFT: String = "margin-left";
		public static const CSS_KEY_MARGINRIGHT: String = "margin-right";
		public static const CSS_KEY_MARGINTOP: String = "margin-top";
		public static const CSS_KEY_MARGINBOTTOM: String = "margin-bottom";
		public static const CSS_KEY_PADDING: String = "padding";
		public static const CSS_KEY_PADDINGLEFT: String = "padding-left";
		public static const CSS_KEY_PADDINGRIGHT: String = "padding-right";
		public static const CSS_KEY_PADDINGTOP: String = "padding-top";
		public static const CSS_KEY_PADDINGBOTTOM: String = "padding-bottom";
		public static const CSS_KEY_BORDERCOLOR: String = "border-color";
		public static const CSS_KEY_BORDERWIDTH: String = "border-width";
		public static const CSS_KEY_BORDERWIDTHLEFT: String = "border-left-width";
		public static const CSS_KEY_BORDERWIDTHRIGHT: String = "border-right-width";
		public static const CSS_KEY_BORDERWIDTHTOP: String = "border-top-width";
		public static const CSS_KEY_BORDERWIDTHBOTTOM: String = "border-bottom-width";
		public static const CSS_KEY_PAGE_BREAK_AFTER: String = "page-break-after";
		public static const CSS_KEY_PAGE_BREAK_BEFORE: String = "page-break-before";
		public static const CSS_KEY_TEXTALIGN: String = "text-align";
		public static const CSS_KEY_TEXTDECORATION: String = "text-decoration";
		public static const CSS_KEY_VERTICALALIGN: String = "vertical-align";
		public static const CSS_KEY_VISIBILITY: String = "visibility";
		public static const CSS_VALUE_ALWAYS: String = "always";
		public static const CSS_VALUE_BLOCK: String = "block";
		public static const CSS_VALUE_BOLD: String = "bold";
		public static const CSS_VALUE_HIDDEN: String = "hidden";
		public static const CSS_VALUE_INLINE: String = "inline";
		public static const CSS_VALUE_ITALIC: String = "italic";
		public static const CSS_VALUE_LINETHROUGH: String = "line-through";
		public static const CSS_VALUE_LISTITEM: String = "list-item";
		public static const CSS_VALUE_NONE: String = "none";
		public static const CSS_VALUE_NORMAL: String = "normal";
		public static const CSS_VALUE_OBLIQUE: String = "oblique";
		public static const CSS_VALUE_TABLE: String = "table";
		public static const CSS_VALUE_TABLEROW: String = "table-row";
		public static const CSS_VALUE_TABLECELL: String = "table-cell";
		public static const CSS_VALUE_TEXTALIGNLEFT: String = "left";
		public static const CSS_VALUE_TEXTALIGNRIGHT: String = "right";
		public static const CSS_VALUE_TEXTALIGNCENTER: String = "center";
		public static const CSS_VALUE_TEXTALIGNJUSTIFY: String = "justify";
		public static const CSS_VALUE_UNDERLINE: String = "underline";
		public static const DEFAULT_FONT_SIZE: Number = 12;
		
		/**
		 * Parses a length.
		 * 
		 * @param string
		 *            a length in the form of an optional + or -, followed by a
		 *            number and a unit.
		 * @return a float
		 */
		
		public static function parseLength1( string: String ): Number
		{
			var pos: int = 0;
			var length: int = string.length;
			var ok: Boolean = true;
			while( ok && pos < length )
			{
				switch (string.charAt(pos)) {
					case '+':
					case '-':
					case '0':
					case '1':
					case '2':
					case '3':
					case '4':
					case '5':
					case '6':
					case '7':
					case '8':
					case '9':
					case '.':
						pos++;
						break;
					default:
						ok = false;
				}
			}
			if (pos == 0)
				return 0;
			if (pos == length)
				return parseFloat(string);
			var f: Number = parseFloat(string.substring(0, pos));
			string = string.substr(pos);
			if ( StringUtils.startsWith(string, "in"))
				return f * 72;
			
			if (StringUtils.startsWith( string, "cm"))
				return (f / 2.54) * 72;

			if ( StringUtils.startsWith( string, "mm"))
				return (f / 25.4) * 72;

			if (StringUtils.startsWith( string, "pc"))
				return f * 12;
			return f;
		}
		
		/**
		 * New method contributed by: Lubos Strapko
		 * 
		 * @since 2.1.3
		 */
		public static function parseLength2( string: String, actualFontSize: Number): Number {
			if (string == null)
				return 0;
			var pos: int = 0;
			var length: int = string.length;
			var ok: Boolean = true;
			while (ok && pos < length) {
				switch (string.charAt(pos)) {
					case '+':
					case '-':
					case '0':
					case '1':
					case '2':
					case '3':
					case '4':
					case '5':
					case '6':
					case '7':
					case '8':
					case '9':
					case '.':
						pos++;
						break;
					default:
						ok = false;
				}
			}
			if (pos == 0)
				return 0;
			if (pos == length)
				return parseFloat(string + "f");
			var f: Number = parseFloat(string.substring(0, pos) );
			string = string.substr(pos);

			if ( StringUtils.startsWith( string, "in"))
				return f * 72;
			
			if ( StringUtils.startsWith( string , "cm"))
				return (f / 2.54) * 72;
			
			if ( StringUtils.startsWith( string, "mm"))
				return (f / 25.4) * 72;
			
			if ( StringUtils.startsWith( string, "pc"))
				return f * 12;
			
			if (StringUtils.startsWith( string, "em"))
				return f * actualFontSize;
			
			if ( StringUtils.startsWith( string, "ex"))
				return f * actualFontSize / 2;
			
			return f;
		}
	}
}