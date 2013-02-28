/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfCrossReferenceCollection.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/collections/PdfCrossReferenceCollection.as $
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
package org.purepdf.collections
{
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.IIterable;
	import org.purepdf.collections.iterator.PdfCrossReferenceCollectionIterator;
	import org.purepdf.pdf.PdfCrossReference;
	import org.purepdf.utils.pdf_core;

	public class PdfCrossReferenceCollection implements IIterable
	{
		use namespace pdf_core;
		
		pdf_core var indices: Vector.<int>;
		pdf_core var values: Vector.<PdfCrossReference>;
		pdf_core var real_indices: Vector.<int>;
		
		protected var dirty: Boolean = false;

		public function PdfCrossReferenceCollection()
		{
			indices = new Vector.<int>();
			values = new Vector.<PdfCrossReference>();
		}
		
		public function get realIndices(): Vector.<int>
		{
			if( dirty )
				validateIndices();
			return real_indices;
		}
		
		public function get length(): int
		{
			if( dirty )
				validateIndices();
			
			return indices.length;
		}
		
		public function iterator(): Iterator
		{
			return new PdfCrossReferenceCollectionIterator( this );
		}
		
		/**
		 * Returns the <code>PdfCrossReference</code> at the specified
		 * refnum
		 * 
		 */
		public function getElement( refnum: int ): PdfCrossReference
		{
			return values[refnum];
		}

		public function add( element: PdfCrossReference ): Boolean
		{
			var refnum: int = element._refnum;

			if( refnum >= values.length || values[refnum] != null )
			{
				values[refnum] = element;
				indices[refnum] = refnum;
				dirty = true;
				return true;
			}

			return false;
		}

		public function remove( element: PdfCrossReference ): Boolean
		{
			var refnum: int = element._refnum;

			if ( values[refnum] != null )
				return false;

			dirty = true;
			values.splice( refnum, 1 );
			indices.splice( refnum, 1 );

			return true;
		}
		
		private function validateIndices(): void
		{
			real_indices = indices.filter( filterIndices );
			real_indices.sort( compareIndices );
			dirty = false;
		}
		
		public function get first(): PdfCrossReference
		{
			if( dirty )
				validateIndices();
			
			return values[real_indices[0]];
		}
		
		public function get last(): PdfCrossReference
		{
			if( dirty )
				validateIndices();
			
			return values[ real_indices[ indices.length - 1 ] ];
		}
		
		private function compareIndices( a: int, b: int ): Number
		{
			return a - b;
		}
		
		private function filterIndices( value: int, index: int, array: Object = null ): Boolean
		{
			return !isNaN( value );
		}
	}
}