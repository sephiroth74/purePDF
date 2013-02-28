/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfStructureTreeRoot.as 275 2010-02-06 17:37:43Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 275 $ $LastChangedDate: 2010-02-06 12:37:43 -0500 (Sat, 06 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfStructureTreeRoot.as $
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
	import org.purepdf.utils.pdf_core;

	public class PdfStructureTreeRoot extends PdfDictionary
	{
		use namespace pdf_core;

		private var _reference: PdfIndirectReference;
		private var _writer: PdfWriter;

		private var parentTree: HashMap = new HashMap();

		public function PdfStructureTreeRoot( writer: PdfWriter )
		{
			super( PdfName.STRUCTTREEROOT );
			_writer = writer;
			_reference = writer.pdfIndirectReference;
		}

		/**
		 * Maps the user tags to the standard tags.
		 * The mapping will allow a standard application to make some sense of the tagged
		 * document whatever the user tags may be.
		 *
		 * @param used the user tag
		 * @param standard the standard tag
		 */
		public function mapRole( used: PdfName, standard: PdfName ): void
		{
			var rm: PdfDictionary = getValue( PdfName.ROLEMAP ) as PdfDictionary;
			if ( rm == null )
			{
				rm = new PdfDictionary();
				put( PdfName.ROLEMAP, rm );
			}
			rm.put( used, standard );
		}

		public function get reference(): PdfIndirectReference
		{
			return _reference;
		}

		public function get writer(): PdfWriter
		{
			return _writer;
		}

		/**
		 * @throws IOError
		 */
		internal function buildTree(): void
		{
			var numTree: HashMap = new HashMap();
			var i: int;
			var ar: PdfArray;
			for ( var it: Iterator = parentTree.keySet().iterator(); it.hasNext();  )
			{
				i = int( it.next() );
				ar = PdfArray( parentTree.getValue( i ) );
				numTree.put( i, writer.addToBody( ar ).indirectReference );
			}
			var dicTree: PdfDictionary = PdfNumberTree.writeTree( numTree, writer );
			if ( dicTree != null )
				put( PdfName.PARENTTREE, writer.addToBody( dicTree ).indirectReference );

			nodeProcess( this, reference );
		}

		/**
		 *
		 * @throws IOError
		 */
		private function nodeProcess( struc: PdfDictionary, reference: PdfIndirectReference ): void
		{
			var obj: PdfObject = struc.getValue( PdfName.K );
			if ( obj != null && obj.isArray() && !PdfObject( PdfArray( obj ).getArrayList()[0] ).isNumber() )
			{
				var ar: PdfArray = PdfArray( obj );
				var a: Vector.<PdfObject> = ar.getArrayList();
				var e: PdfStructureElement;
				for ( var k: int = 0; k < a.length; ++k )
				{
					e = PdfStructureElement( a[k] );
					a[k] = e.reference;
					nodeProcess( e, e.reference );
				}
			}
			if ( reference != null )
				writer.addToBody1( struc, reference );
		}

		internal function setPageMark( page: int, struc: PdfIndirectReference ): void
		{
			var i: int = page;
			var ar: PdfArray = parentTree.getValue( i ) as PdfArray;
			if ( ar == null )
			{
				ar = new PdfArray();
				parentTree.put( i, ar );
			}
			ar.add( struc );
		}
	}
}