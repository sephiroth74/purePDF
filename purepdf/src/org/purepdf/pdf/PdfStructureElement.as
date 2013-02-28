/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfStructureElement.as 275 2010-02-06 17:37:43Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 275 $ $LastChangedDate: 2010-02-06 12:37:43 -0500 (Sat, 06 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfStructureElement.as $
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
	import org.purepdf.utils.pdf_core;
	
	/**
	 * This is a node in a document logical structure.
	 * It may contain a mark point or it may contain other nodes.
	 */
	public class PdfStructureElement extends PdfDictionary
	{
		private var _parent: PdfStructureElement;
		private var _reference: PdfIndirectReference;
		private var top: PdfStructureTreeRoot;

		public function PdfStructureElement()
		{
			super();
		}

		/**
		 * Return this node parent
		 */
		public function get parent(): PdfStructureElement
		{
			return _parent;
		}

		/**
		 * Gets the reference this object will be written to.
		 */    
		public function get reference(): PdfIndirectReference
		{
			return _reference;
		}

		private function init( parent: PdfDictionary, structureType: PdfName ): void
		{
			var kido: PdfObject = parent.getValue( PdfName.K );
			var kids: PdfArray = null;
			if ( kido != null && !kido.isArray() )
				throw new ArgumentError( "the parent has already another function" );
			if ( kido == null )
			{
				kids = new PdfArray();
				parent.put( PdfName.K, kids );
			} else
				kids = PdfArray( kido );
			kids.add( this );
			put( PdfName.S, structureType );
			_reference = top.writer.pdfIndirectReference;
		}

		pdf_core function setPageMark( page: int, mark: int ): void
		{
			if ( mark >= 0 )
				put( PdfName.K, new PdfNumber( mark ) );
			top.setPageMark( page, _reference );
		}

		/**
		 * @throws ArgumentError
		 */
		public static function createElement( parent: PdfStructureElement, structureType: PdfName ): PdfStructureElement
		{
			var ret: PdfStructureElement = new PdfStructureElement();
			ret.top = parent.top;
			ret.init( parent, structureType );
			ret._parent = parent;
			ret.put( PdfName.P, parent._reference );
			return ret;
		}

		/**
		 * @throws ArgumentError
		 */
		public static function createRoot( parent: PdfStructureTreeRoot, structureType: PdfName ): PdfStructureElement
		{
			var ret: PdfStructureElement = new PdfStructureElement();
			ret.top = parent;
			ret.init( parent, structureType );
			ret.put( PdfName.P, parent.reference );
			return ret;
		}
	}
}