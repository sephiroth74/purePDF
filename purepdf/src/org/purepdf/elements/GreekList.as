/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: GreekList.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/GreekList.as $
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
	import org.purepdf.Font;
	import org.purepdf.factories.FontFactory;
	import org.purepdf.factories.GreekAlphabetFactory;
	import org.purepdf.pdf.fonts.BaseFont;

	public class GreekList extends List
	{
		public function GreekList( $symbolIndent: Number = 0 )
		{
			super( true, $symbolIndent );
			setGreekFont();
		}

		override public function add( o: Object ): Boolean
		{
			if ( o is ListItem )
			{
				var item: ListItem = ListItem( o );
				var chunk: Chunk = new Chunk( preSymbol, symbol.font );
				chunk.append( GreekAlphabetFactory.getString( first + list.length, lowercase ) );
				chunk.append( postSymbol );
				item.listSymbol = chunk;
				item.setIndentationLeft( symbolIndent, autoindent );
				item.indentationRight = 0;
				list.push( item );
				return true;
			} else if ( o is List )
			{
				var nested: List = List( o );
				nested.indentationLeft = nested.indentationLeft + symbolIndent;
				first--;
				list.push( nested );
				return true;
			} else if ( o is String )
			{
				return add( new ListItem( String( o ) ) );
			}
			return false;
		}

		protected function setGreekFont(): void
		{
			var fontsize: Number = symbol.font.size;
			symbol.font = FontFactory.getFont( BaseFont.SYMBOL, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED, fontsize, Font.NORMAL );
		}
	}
}