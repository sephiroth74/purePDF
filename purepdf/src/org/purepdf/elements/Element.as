/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Element.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/Element.as $
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
	[Abstract]
	public final class Element
	{
		public static const ALIGN_BASELINE: int = 7;
		public static const ALIGN_BOTTOM: int = 6;
		public static const ALIGN_CENTER: int = 1;
		public static const ALIGN_JUSTIFIED: int = 3;
		public static const ALIGN_JUSTIFIED_ALL: int = 8;
		public static const ALIGN_LEFT: int = 0;
		public static const ALIGN_MIDDLE: int = 5;
		public static const ALIGN_RIGHT: int = 2;
		public static const ALIGN_TOP: int = 4;
		public static const ALIGN_UNDEFINED: int = -1;
		public static const ANCHOR: int = 17;
		public static const ANNOTATION: int = 29;
		public static const AUTHOR: int = 4;
		public static const CCITTG3_1D: int = 0x101;
		public static const CCITTG3_2D: int = 0x102;
		public static const CCITTG4: int = 0x100;
		public static const CCITT_BLACKIS1: int = 1;
		public static const CCITT_ENCODEDBYTEALIGN: int = 2;
		public static const CCITT_ENDOFBLOCK: int = 8;
		public static const CCITT_ENDOFLINE: int = 4;
		public static const CHAPTER: int = 16;
		public static const CHUNK: int = 10;
		public static const CREATIONDATE: int = 6;
		public static const CREATOR: int = 7;
		public static const HEADER: int = 0;
		public static const IMGRAW: int = 34;
		public static const IMGTEMPLATE: int = 35;
		public static const JBIG2: int = 36;
		public static const JPEG: int = 32;
		public static const JPEG2000: int = 33;
		public static const KEYWORDS: int = 3;
		public static const LIST: int = 14;
		public static const LISTITEM: int = 15;
		public static const MARKED: int = 50;
		public static const MULTI_COLUMN_TEXT: int = 40;
		public static const PARAGRAPH: int = 12;
		public static const PHRASE: int = 11;
		public static const PRODUCER: int = 5;
		public static const PTABLE: int = 23;
		public static const RECTANGLE: int = 30;
		public static const SECTION: int = 13;
		public static const SUBJECT: int = 2;
		public static const TITLE: int = 1;
		public static const YMARK: int = 55;
		public static const TABLE: int = 22;
		public static const CELL: int = 20;
	}
}