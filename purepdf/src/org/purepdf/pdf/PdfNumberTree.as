/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfNumberTree.as 262 2010-02-05 00:56:38Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 262 $ $LastChangedDate: 2010-02-04 19:56:38 -0500 (Thu, 04 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfNumberTree.as $
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
	import it.sephiroth.utils.HashMap;
	
	import org.purepdf.utils.pdf_core;

	public class PdfNumberTree
	{
		private static const leafSize: int = 64;
		use namespace pdf_core;
		
		private static function numbersSort( a: int, b: int ): Number
		{
			return a - b;
		}
		
		/**
		 * Creates a number tree
		 * 
		 * @param items the item of the number tree. The key is an <CODE>Integer</CODE>
		 * and the value is a <CODE>PdfObject</CODE>.
		 * @param writer the writer
		 * @return the dictionary with the number tree.
		 */    
		public static function writeTree( items: HashMap, writer: PdfWriter ): PdfDictionary
		{
			if( items.isEmpty() )
				return null;
			
			var k: int;
			var dic: PdfDictionary;
			var ar: PdfArray;
			var numbers: Vector.<int> = new Vector.<int>( items.size(), true );
			numbers = Vector.<int>( items.keySet().toArray( Vector.<Object>(numbers) ) );
			numbers.sort( numbersSort );
			
			if( numbers.length <= leafSize) 
			{
				dic = new PdfDictionary();
				ar = new PdfArray();
				for( k = 0; k < numbers.length; ++k )
				{
					ar.add( new PdfNumber( numbers[k] ) );
					ar.add( PdfObject( items.getValue(numbers[k]) ) );
				}
				dic.put( PdfName.NUMS, ar );
				return dic;
			}
			
			var arr: PdfArray;
			var offset: int;
			var end: int;
			var skip: int = leafSize;
			var kids: Vector.<PdfIndirectReference> = new Vector.<PdfIndirectReference>( (numbers.length + leafSize - 1) / leafSize, true );
			for( k = 0; k < kids.length; ++k )
			{
				offset = k * leafSize;
				end = Math.min(offset + leafSize, numbers.length);
				dic = new PdfDictionary();
				arr = new PdfArray();
				arr.add(new PdfNumber( numbers[offset] ));
				arr.add(new PdfNumber( numbers[end - 1] ));
				dic.put(PdfName.LIMITS, arr);
				arr = new PdfArray();
				for (; offset < end; ++offset) {
					arr.add( new PdfNumber( numbers[offset] ));
					arr.add( PdfObject( items.getValue(numbers[offset])) );
				}
				dic.put(PdfName.NUMS, arr);
				kids[k] = writer.addToBody(dic).indirectReference;
			}
			
			var top: int = kids.length;
			var tt: int;
			while( true )
			{
				if (top <= leafSize) {
					arr = new PdfArray();
					for( k = 0; k < top; ++k )
						arr.add(kids[k]);
					
					dic = new PdfDictionary();
					dic.put(PdfName.KIDS, arr);
					return dic;
				}
				skip *= leafSize;
				tt = (numbers.length + skip - 1 )/ skip;
				for( k = 0; k < tt; ++k )
				{
					offset = k * leafSize;
					end = Math.min(offset + leafSize, top);
					dic = new PdfDictionary();
					arr = new PdfArray();
					arr.add(new PdfNumber(numbers[k * skip]));
					arr.add(new PdfNumber(numbers[Math.min((k + 1) * skip, numbers.length) - 1]));
					dic.put(PdfName.LIMITS, arr);
					arr = new PdfArray();
					for (; offset < end; ++offset) {
						arr.add(kids[offset]);
					}
					dic.put(PdfName.KIDS, arr);
					kids[k] = writer.addToBody(dic).indirectReference;
				}
				top = tt;
			}
			return null;
		}
	}
}