/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfArray.as 332 2010-02-14 19:57:16Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 332 $ $LastChangedDate: 2010-02-14 14:57:16 -0500 (Sun, 14 Feb 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfArray.as $
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
	import it.sephiroth.utils.collections.iterators.Iterator;
	import org.purepdf.errors.IndexOutOfBoundsError;
	import org.purepdf.pdf.interfaces.IOutputStream;
	import org.purepdf.utils.iterators.VectorIterator;

	public class PdfArray extends PdfObject
	{
		protected var arrayList: Vector.<PdfObject>;

		/**
		 * Supported constructor types:<br>
		 * <ul>
		 * <li>PdfObject</li>
		 * <li>Vector.&lt;Number&gt;</li>
		 * <li>Vector.&lt;int&gt;</li>
		 * </ul>
		 */
		public function PdfArray( object: Object = null )
		{
			super( ARRAY );
			arrayList = new Vector.<PdfObject>();

			if ( object )
			{
				if ( object is PdfObject )
					arrayList.push( object );
				else if ( object is Vector.<Number> )
					add2( Vector.<Number>( object ) );
				else if ( object is Vector.<int> )
					add3( Vector.<int>( object ) );
			}
		}

		/**
		 * Add a PdfObject to the end of the PdfArray
		 *
		 */
		public function add( object: PdfObject ): uint
		{
			return arrayList.push( object );
		}

		/**
		 * Add an array of numbers to the end of the PdfArray
		 *
		 */
		public function add2( values: Vector.<Number> ): Boolean
		{
			for ( var k: int = 0; k < values.length; ++k )
				arrayList.push( new PdfNumber( values[k] ) );
			return true;
		}

		/**
		 * Add and array of integer to the end of the PdfArray
		 *
		 */
		public function add3( values: Vector.<int> ): Boolean
		{
			for ( var k: int = 0; k < values.length; ++k )
				arrayList.push( new PdfNumber( values[k] ) );
			return true;
		}

		public function addFirst( object: PdfObject ): void
		{
			arrayList.splice( 0, 0, object );
		}

		/**
		 * Check if the PdfArray already contains a certain PdfObject
		 * @param object
		 * @return
		 */
		public function contains( object: PdfObject ): Boolean
		{
			return arrayList.indexOf( object ) > -1;
		}

		[Deprecated]
		public function getArrayList(): Vector.<PdfObject>
		{
			return arrayList;
		}

		/**
		 * Returns a <code>PdfObject</code> as a <code>PdfNumber</code>,
		 * resolving indirect references.
		 *
		 * The object corresponding to the specified index is retrieved and
		 * resolved to a direct object.
		 * If it is a <code>PdfNumber</code>, it is cast down and returned as such.
		 * Otherwise <code>null</code> is returned.
		 *
		 * @param idx The index of the <code>PdfObject</code> to be returned
		 * @return the corresponding <code>PdfNumber</code> object,
		 *   or <code>null</code>
		 */
		public function getAsNumber( idx: int ): PdfNumber
		{
			var number: PdfNumber = null;
			var orig: PdfObject = getDirectObject( idx );
			if ( orig != null && orig.isNumber() )
				number = PdfNumber( orig );
			return number;
		}

		/**
		 * Returns the <code>PdfObject</code> with the specified index, resolving
		 * a possible indirect reference to a direct object.
		 *
		 * Thus this method will never return a <code>PdfIndirectReference</code>
		 * object.
		 *
		 * @param idx The index of the <code>PdfObject</code> to be returned
		 * @return A direct <code>PdfObject</code> or <code>null</code>
		 */
		public function getDirectObject( idx: int ): PdfObject
		{
			return PdfReader.getPdfObject( getPdfObject( idx ) );
		}

		/**
		 * Returns the PdfObject at the specified index
		 *
		 */
		public function getPdfObject( idx: int ): PdfObject
		{
			return PdfObject( arrayList[idx] );
		}

		public function get isEmpty(): Boolean
		{
			return arrayList.length == 0;
		}

		/**
		 * Returns the list iterator for the array.
		 *
		 * @return a ListIterator
		 */
		public function listIterator(): Iterator
		{
			return new VectorIterator( Vector.<Object>( arrayList ) );
		}

		/**
		 * Remove the element at the specified position from the array.
		 *
		 * Shifts any subsequent elements to the left (subtracts one from their
		 * indices).
		 *
		 * @param idx The index of the element to be removed.
		 * @throws IndexOutOfBoundsError
		 */
		public function remove( idx: int ): PdfObject
		{
			return arrayList.splice( idx, 1 ) as PdfObject;
		}

		public function get size(): int
		{
			return arrayList.length;
		}

		/**
		 * Writes the PDF representation of this <CODE>PdfArray</CODE> as an array
		 * of <CODE>byte</CODE> to the specified <CODE>OutputStream</CODE>.
		 *
		 * @param writer for backwards compatibility
		 * @param os the <CODE>OutputStream</CODE> to write the bytes to.
		 */
		override public function toPdf( writer: PdfWriter, os: IOutputStream ): void
		{
			os.writeInt( '['.charCodeAt( 0 ) );
			var object: PdfObject;
			var t: int = 0;
			var i: VectorIterator = new VectorIterator( Vector.<Object>( arrayList ) );

			if ( i.hasNext() )
			{
				object = i.next();

				if ( object == null )
					object = PdfNull.PDFNULL;
				object.toPdf( writer, os );
			}

			while ( i.hasNext() )
			{
				object = i.next();

				if ( object == null )
					object = PdfNull.PDFNULL;
				t = object.getType();

				if ( t != PdfObject.ARRAY && t != PdfObject.DICTIONARY && t != PdfObject.NAME && t != PdfObject.STRING )
					os.writeInt( ' '.charCodeAt( 0 ) );
				object.toPdf( writer, os );
			}
			os.writeInt( ']'.charCodeAt( 0 ) );
		}

		override public function toString(): String
		{
			var str: String = "[";

			for ( var a: int = 0; a < arrayList.length; a++ )
			{
				str += arrayList[a].toString();

				if ( ( a + 1 ) < arrayList.length )
					str += ", ";
			}
			str += "]";
			return str;
		}
	}
}