/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfAcroForm.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfAcroForm.as $
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
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.pdf.forms.PdfFormField;
	import org.purepdf.utils.pdf_core;

	public class PdfAcroForm extends PdfDictionary
	{
		use namespace pdf_core;
		
		private var calculationOrder: PdfArray = new PdfArray();
		private var documentFields: PdfArray = new PdfArray();
		private var fieldTemplates: HashMap = new HashMap();
		private var sigFlags: int = 0;
		private var writer: PdfWriter;

		public function PdfAcroForm( $writer: PdfWriter )
		{
			super();
			writer = $writer;
		}

		public function addDocumentField( ref: PdfIndirectReference ): void
		{
			documentFields.add( ref );
		}

		public function addFieldTemplates( ft: HashMap ): void
		{
			fieldTemplates.putAll( ft );
		}
		
		public function get valid(): Boolean
		{
			if (documentFields.size == 0) return false;
			put(PdfName.FIELDS, documentFields);
			if (sigFlags != 0)
				put(PdfName.SIGFLAGS, new PdfNumber(sigFlags));
			if (calculationOrder.size > 0)
				put(PdfName.CO, calculationOrder);
			if (fieldTemplates.isEmpty()) return true;
			var dic: PdfDictionary = new PdfDictionary();
			
			for (var it: Iterator = fieldTemplates.keySet().iterator(); it.hasNext();) 
			{
				var template: PdfTemplate = PdfTemplate( it.next() );
				PdfFormField.mergeResources(dic, PdfDictionary(template.resources));
			}
			put(PdfName.DR, dic);
			put(PdfName.DA, new PdfString("/Helv 0 Tf 0 g "));
			var fonts: PdfDictionary = dic.getValue(PdfName.FONT) as PdfDictionary;
			if (fonts != null) {
				writer.eliminateFontSubset(fonts);
			}
			return true;
		}
	}
}