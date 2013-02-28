/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfPageLabels.as 262 2010-02-05 00:56:38Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 262 $ $LastChangedDate: 2010-02-04 19:56:38 -0500 (Thu, 04 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfPageLabels.as $
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
	import flash.errors.IOError;
	
	import it.sephiroth.utils.HashMap;
	
	import org.purepdf.errors.ConversionError;

	public class PdfPageLabels
	{
		public static const DECIMAL_ARABIC_NUMERALS: int = 0;
		public static const UPPERCASE_ROMAN_NUMERALS: int = 1;
		public static const LOWERCASE_ROMAN_NUMERALS: int = 2;
		public static const UPPERCASE_LETTERS: int = 3;
		public static const LOWERCASE_LETTERS: int = 4;
		public static const EMPTY: int = 5;
		private static const numberingStyle: Vector.<PdfName> = Vector.<PdfName>([ PdfName.D, PdfName.R, new PdfName("r"), PdfName.A, new PdfName("a")] );
		private var map: HashMap;
		
		public function PdfPageLabels()
		{
			map = new HashMap();
			addPageLabel(1, DECIMAL_ARABIC_NUMERALS, null, 1);
		}
		
		/** 
		 * Add or replace a page label.
		 * 
		 * @param page the real page to start the numbering. First page is 1
		 * @param numberStyle the numbering style such as LOWERCASE_ROMAN_NUMERALS
		 * @param text the text to prefix the number. Can be <CODE>null</CODE> or empty
		 * @param firstPage the first logical page number
		 * 
		 * @see #DECIMAL_ARABIC_NUMERALS
		 * @see #UPPERCASE_ROMAN_NUMERALS
		 * @see #LOWERCASE_ROMAN_NUMERALS
		 * @see #UPPERCASE_LETTERS
		 * @see #LOWERCASE_LETTERS
		 * @see #EMPTY
		 * 
		 * @throws ArgumentError
		 */    
		public function addPageLabel( page: int, numberStyle: int, text: String = null, firstPage: int = 1 ): void
		{
			if( page < 1 || firstPage < 1 )
				throw new ArgumentError( "in a page label the page numbers must be >= 1" );
			var dic: PdfDictionary = new PdfDictionary();
			if( numberStyle >= 0 && numberStyle < numberingStyle.length )
				dic.put( PdfName.S, numberingStyle[numberStyle] );
			if (text != null)
				dic.put( PdfName.P, new PdfString( text, PdfObject.TEXT_UNICODE ) );
			if( firstPage != 1 )
				dic.put( PdfName.ST, new PdfNumber(firstPage) );
			map.put(page - 1, dic);
		}
		
		/** 
		 * Remove a page label. 
		 * The first page label can not be removed, only changed.
		 * 
		 * @param page the real page to remove
		 * @return true if page label has been removed
		 */    
		public function removePageLabel( page: int ): Boolean
		{
			if (page <= 1)
				return false;
			map.remove( page - 1 );
			return true;
		}
		
		/** 
		 * Gets the page label dictionary to insert into the document.
		 * 
		 * @return the page label dictionary
		 * @throws ConversionError
		 */    
		internal function getDictionary( writer: PdfWriter ): PdfDictionary
		{
			try 
			{
				return PdfNumberTree.writeTree( map, writer );
			}
			catch( e: IOError )
			{
				throw new ConversionError( e );
			}
			return null;
		}
		
	}
}