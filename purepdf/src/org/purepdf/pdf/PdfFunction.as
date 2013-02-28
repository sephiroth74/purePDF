/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfFunction.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfFunction.as $
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
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.utils.pdf_core;
	
	

	public class PdfFunction extends ObjectHash
	{
		protected var writer: PdfWriter;
		private var _reference: PdfIndirectReference;
		protected var dictionary: PdfDictionary;
		
		use namespace pdf_core;
		
		public function PdfFunction( $writer: PdfWriter )
		{
			writer = $writer;
		}
		
		public function get reference(): PdfIndirectReference
		{
			if( _reference == null )
				_reference = writer.addToBody( dictionary ).indirectReference;
			return _reference;
		}
		
		public static function type2( writer: PdfWriter, domain: Vector.<Number>, range: Vector.<Number>, c0: Vector.<Number>, c1: Vector.<Number>, n: Number ): PdfFunction
		{
			var func: PdfFunction = new PdfFunction(writer);
			func.dictionary = new PdfDictionary();
			func.dictionary.put(PdfName.FUNCTIONTYPE, new PdfNumber(2));
			func.dictionary.put(PdfName.DOMAIN, new PdfArray(domain));
			if (range != null)
				func.dictionary.put(PdfName.RANGE, new PdfArray(range));
			if (c0 != null)
				func.dictionary.put(PdfName.C0, new PdfArray(c0));
			if (c1 != null)
				func.dictionary.put(PdfName.C1, new PdfArray(c1));
			func.dictionary.put(PdfName.N, new PdfNumber(n));
			return func;
		}
		
		public static function type3( writer: PdfWriter, domain: Vector.<Number>, range: Vector.<Number>, functions: Vector.<PdfFunction>, bounds: Vector.<Number>, encode: Vector.<Number> ): PdfFunction
		{
			var func: PdfFunction = new PdfFunction(writer);
			func.dictionary = new PdfDictionary();
			func.dictionary.put(PdfName.FUNCTIONTYPE, new PdfNumber(3));
			func.dictionary.put(PdfName.DOMAIN, new PdfArray(domain));
			if (range != null)
				func.dictionary.put(PdfName.RANGE, new PdfArray(range));
			var array: PdfArray = new PdfArray();
			for (var k: int = 0; k < functions.length; ++k )
				array.add(functions[k].reference );
			func.dictionary.put(PdfName.FUNCTIONS, array);
			func.dictionary.put(PdfName.BOUNDS, new PdfArray(bounds));
			func.dictionary.put(PdfName.ENCODE, new PdfArray(encode));
			return func;
		}
	}
}