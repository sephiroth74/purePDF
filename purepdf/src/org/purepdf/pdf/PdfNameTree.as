/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfNameTree.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfNameTree.as $
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

	public class PdfNameTree
	{
		use namespace pdf_core;
		
		private static const leafSize: int = 64;
		
		/**
		 * Writes a name tree to a PdfWriter.
		 * @param items the item of the name tree. The key is a <CODE>String</CODE>
		 * and the value is a <CODE>PdfObject</CODE>. Note that although the
		 * keys are strings only the lower byte is used and no check is made for chars
		 * with the same lower byte and different upper byte. This will generate a wrong
		 * tree name.
		 * @param writer the writer
		 * @throws IOException on error
		 * @return the dictionary with the name tree. This dictionary is the one
		 * generally pointed to by the key /Dests, for example
		 */    
		public static function writeTree( items: HashMap, writer: PdfWriter ): PdfDictionary
		{
			if (items.isEmpty())
				return null;
			
			var k: int;
			var arr: PdfArray;
			var dic: PdfDictionary;
			var offset: int;
			var end: int;
			
			var names: Vector.<Object> = new Vector.<Object>(items.size());
			names = items.keySet().toArray( Vector.<Object>(names) );
			names.sort( function cmp( a: String, b: String ): Number{ if( a < b ){ return -1 } else if( a > b ){ return 1 } else { return 0 } } );
			if( names.length <= leafSize) 
			{
				dic = new PdfDictionary();
				var ar: PdfArray = new PdfArray();
				for ( k = 0; k < names.length; ++k) {
					ar.add(new PdfString(names[k], null));
					ar.add(items.getValue(names[k]) as PdfObject);
				}
				dic.put(PdfName.NAMES, ar);
				return dic;
			}
			var skip: int = leafSize;
			var kids: Vector.<PdfIndirectReference> = new Vector.<PdfIndirectReference>( (names.length + leafSize - 1) / leafSize, true );
			for( k = 0; k < kids.length; ++k )
			{
				offset = k * leafSize;
				end = Math.min(offset + leafSize, names.length);
				dic = new PdfDictionary();
				arr = new PdfArray();
				arr.add(new PdfString(names[offset], null));
				arr.add(new PdfString(names[end - 1], null));
				dic.put(PdfName.LIMITS, arr);
				arr = new PdfArray();
				for (; offset < end; ++offset) {
					arr.add(new PdfString(names[offset], null));
					arr.add(items.getValue(names[offset]) as PdfObject );
				}
				dic.put(PdfName.NAMES, arr);
				kids[k] = writer.addToBody(dic).indirectReference;
			}
			
			var top: int = kids.length;
			while (true)
			{
				if (top <= leafSize) {
					arr = new PdfArray();
					for ( k = 0; k < top; ++k)
						arr.add(kids[k]);
					dic = new PdfDictionary();
					dic.put(PdfName.KIDS, arr);
					return dic;
				}
				skip *= leafSize;
				var tt: int = (names.length + skip - 1 )/ skip;
				for ( k = 0; k < tt; ++k) {
					offset = k * leafSize;
					end = Math.min(offset + leafSize, top);
					dic = new PdfDictionary();
					arr = new PdfArray();
					arr.add(new PdfString(names[k * skip], null));
					arr.add(new PdfString(names[Math.min((k + 1) * skip, names.length) - 1], null));
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