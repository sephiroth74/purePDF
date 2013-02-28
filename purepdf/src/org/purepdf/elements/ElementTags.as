/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: ElementTags.as 249 2010-02-02 06:59:26Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 249 $ $LastChangedDate: 2010-02-02 01:59:26 -0500 (Tue, 02 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/ElementTags.as $
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
package org.purepdf.elements
{
	public class ElementTags
	{
		public static const ABSOLUTEX: String = "absolutex";
		public static const ABSOLUTEY: String = "absolutey";
		public static const ALIGN: String = "align";
		public static const ALIGN_BASELINE: String = "Baseline";
		public static const ALIGN_BOTTOM: String = "Bottom";
		public static const ALIGN_CENTER: String = "Center";
		public static const ALIGN_INDENTATION_ITEMS: String = "alignindent";
		public static const ALIGN_JUSTIFIED: String = "Justify";
		public static const ALIGN_JUSTIFIED_ALL: String = "JustifyAll";
		public static const ALIGN_LEFT: String = "Left";
		public static const ALIGN_MIDDLE: String = "Middle";
		public static const ALIGN_RIGHT: String = "Right";
		public static const ALIGN_TOP: String = "Top";
		public static const ALT: String = "alt";
		public static const ANCHOR: String = "anchor";
		public static const ANNOTATION: String = "annotation";
		public static const APPLICATION: String = "application";
		public static const AUTHOR: String = "author";
		public static const AUTO_INDENT_ITEMS: String = "autoindent";
		public static const BACKGROUNDCOLOR: String = "backgroundcolor";
		public static const BGBLUE: String = "bgblue";
		public static const BGGREEN: String = "bggreen";
		public static const BGRED: String = "bgred";
		public static const BLUE: String = "blue";
		public static const BORDERCOLOR: String = "bordercolor";
		public static const BORDERWIDTH: String = "borderwidth";
		public static const BOTTOM: String = "bottom";
		public static const CELL: String = "cell";
		public static const CELLPADDING: String = "cellpadding";
		public static const CELLSFITPAGE: String = "cellsfitpage";
		public static const CELLSPACING: String = "cellspacing";
		public static const CHAPTER: String = "chapter";
		public static const CHUNK: String = "chunk";
		public static const COLOR: String = "color";
		public static const COLSPAN: String = "colspan";
		public static const COLUMNS: String = "columns";
		public static const CONTENT: String = "content";
		public static const CONVERT2PDFP: String = "convert2pdfp";
		public static const CREATIONDATE: String = "creationdate";
		public static const DEFAULT: String = "Default";
		public static const DEFAULTDIR: String = "defaultdir";
		public static const DEPTH: String = "depth";
		public static const DESTINATION: String = "destination";
		public static const EMBEDDED: String = "embedded";
		public static const ENCODING: String = "encoding";
		public static const ENTITY: String = "entity";
		public static const FACE: String = "face";
		public static const FILE: String = "file";
		public static const FIRST: String = "first";
		public static const FONT: String = "font";
		public static const GENERICTAG: String = Chunk.GENERICTAG.toLowerCase();
		public static const GRAYFILL: String = "grayfill";
		public static const GREEN: String = "green";
		public static const HEADER: String = "header";
		public static const HORIZONTALALIGN: String = "horizontalalign";
		public static const HORIZONTALRULE: String = "horizontalrule";
		public static const ID: String = "id";
		public static const IGNORE: String = "ignore";
		public static const IMAGE: String = "image";
		public static const INDENT: String = "indent";
		public static const INDENTATIONLEFT: String = "indentationleft";
		public static const INDENTATIONRIGHT: String = "indentationright";
		public static const ITEXT: String = "itext";
		public static const KEEPTOGETHER: String = "keeptogether";
		public static const KEYWORDS: String = "keywords";
		public static const LASTHEADERROW: String = "lastHeaderRow";
		public static const LEADING: String = "leading";
		public static const LEFT: String = "left";
		public static const LETTERED: String = "lettered";
		public static const LIST: String = "list";
		public static const LISTITEM: String = "listitem";
		public static const LISTSYMBOL: String = "listsymbol";
		public static const LLX: String = "llx";
		public static const LLY: String = "lly";
		public static const LOCALDESTINATION: String = Chunk.LOCALDESTINATION.toLowerCase();
		public static const LOCALGOTO: String = Chunk.LOCALGOTO.toLowerCase();
		public static const LOWERCASE: String = "lowercase";
		public static const NAME: String = "name";
		public static const NAMED: String = "named";
		public static const NEWLINE: String = "newline";
		public static const NEWPAGE: String = "newpage";
		public static const NOWRAP: String = "nowrap";
		public static const NUMBER: String = "number";
		public static const NUMBERDEPTH: String = "numberdepth";
		public static const NUMBERED: String = "numbered";
		public static const OFFSET: String = "offset";
		public static const OPERATION: String = "operation";
		public static const ORIENTATION: String  = "orientation";
		public static const PAGE: String = "page";
		public static const PAGE_SIZE: String  = "pagesize";
		public static const PARAGRAPH: String = "paragraph";
		public static const PARAMETERS: String = "parameters";
		public static const PHRASE: String = "phrase";
		public static const PLAINHEIGHT: String = "plainheight";
		public static const PLAINWIDTH: String = "plainwidth";
		public static const PRODUCER: String = "producer";
		public static const RED: String = "red";
		public static const REFERENCE: String = "reference";
		public static const REMOTEGOTO: String = Chunk.REMOTEGOTO.toLowerCase();
		public static const RIGHT: String = "right";
		public static const ROTATION: String = "rotation";
		public static const ROW: String = "row";
		public static const ROWSPAN: String = "rowspan";
		public static const SCALEDHEIGHT: String = "scaledheight";
		public static const SCALEDWIDTH: String = "scaledwidth";
		public static const SECTION: String = "section";
		public static const SIZE: String = "size";
		public static const SRC: String = "src";
		public static const STYLE: String = "fontstyle";
		public static const SUBJECT: String = "subject";
		public static const SUBSUPSCRIPT: String = Chunk.SUBSUPSCRIPT.toLowerCase();
		public static const SYMBOLINDENT: String = "symbolindent";
		public static const TABLE: String = "table";
		public static const TABLEFITSPAGE: String = "tablefitspage";
		public static const TEXTWRAP: String = "textwrap";
		public static const TITLE: String = "title";
		public static const TOP: String = "top";
		public static const UNDERLYING: String = "underlying";
		public static const UNKNOWN: String = "unknown";
		public static const URL: String = "url";
		public static const URX: String = "urx";
		public static const URY: String = "ury";
		public static const VERTICALALIGN: String = "verticalalign";
		public static const WIDTH: String = "width";
		public static const WIDTHS: String = "widths";

		/**
		 * Translates a String value to an alignment value.
		 * @param	alignment a String (one of the ALIGN_ constants of this class)
		 * @return	an alignment value (one of the ALIGN_ constants of the Element interface)
		 */
		public static function alignmentValue( alignment: String ): int
		{
			if ( alignment == null )
				return Element.ALIGN_UNDEFINED;

			else if ( ALIGN_CENTER.toLowerCase() == alignment.toLowerCase() )
				return Element.ALIGN_CENTER;

			else if ( ALIGN_LEFT.toLowerCase() == alignment.toLowerCase() )
				return Element.ALIGN_LEFT;

			else if ( ALIGN_RIGHT.toLowerCase() == alignment.toLowerCase() )
				return Element.ALIGN_RIGHT;

			else if ( ALIGN_JUSTIFIED.toLowerCase() == alignment.toLowerCase() )
				return Element.ALIGN_JUSTIFIED;

			else if ( ALIGN_JUSTIFIED_ALL.toLowerCase() == alignment.toLowerCase() )
				return Element.ALIGN_JUSTIFIED_ALL;

			else if ( ALIGN_TOP.toLowerCase() == alignment.toLowerCase() )
				return Element.ALIGN_TOP;

			else if ( ALIGN_MIDDLE.toLowerCase() == alignment.toLowerCase() )
				return Element.ALIGN_MIDDLE;

			else if ( ALIGN_BOTTOM.toLowerCase() == alignment.toLowerCase() )
				return Element.ALIGN_BOTTOM;

			else if ( ALIGN_BASELINE.toLowerCase() == alignment.toLowerCase() )
				return Element.ALIGN_BASELINE;
			
			return Element.ALIGN_UNDEFINED;
		}

		/**
		 * Translates the alignment value to a String value.
		 *
		 * @param   alignment   the alignment value
		 * @return  the translated value
		 */
		public static function getAlignment( alignment: int ): String
		{
			switch ( alignment )
			{
				case Element.ALIGN_LEFT:
					return ALIGN_LEFT;
				case Element.ALIGN_CENTER:
					return ALIGN_CENTER;
				case Element.ALIGN_RIGHT:
					return ALIGN_RIGHT;
				case Element.ALIGN_JUSTIFIED:
				case Element.ALIGN_JUSTIFIED_ALL:
					return ALIGN_JUSTIFIED;
				case Element.ALIGN_TOP:
					return ALIGN_TOP;
				case Element.ALIGN_MIDDLE:
					return ALIGN_MIDDLE;
				case Element.ALIGN_BOTTOM:
					return ALIGN_BOTTOM;
				case Element.ALIGN_BASELINE:
					return ALIGN_BASELINE;
				default:
					return DEFAULT;
			}
		}
	}
}