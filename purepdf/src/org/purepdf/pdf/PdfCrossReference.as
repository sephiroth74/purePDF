/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfCrossReference.as 362 2010-05-05 16:53:53Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 362 $ $LastChangedDate: 2010-05-05 12:53:53 -0400 (Wed, 05 May 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfCrossReference.as $
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
	
	import org.purepdf.IComparable;
	import org.purepdf.pdf.interfaces.IOutputStream;
	import org.purepdf.utils.assert_true;
	import org.purepdf.utils.pdf_core;

	public final class PdfCrossReference extends ObjectHash implements IComparable
	{
		use namespace pdf_core;
		
		private var generation: int;
		private var offset: int;
		pdf_core var _refnum: int;
		private var type: int;

		/**
		 * Constructs a cross-reference element for a PdfIndirectObject.
		 * @param refnum
		 * @param	offset		byte offset of the object
		 * @param	generation	generation number of the object
		 */
		public function PdfCrossReference( $type: int, $refnum: int, $offset: int, $generation: int=0 )
		{
			type = $type;
			offset = $offset;
			_refnum = $refnum;
			generation = $generation;
		}

		public function compareTo( o: Object ): int
		{
			var other: PdfCrossReference = o as PdfCrossReference;
			return _refnum - other._refnum;
			//return ( refnum < other.refnum ? -1 : ( refnum == other.refnum ? 0 : 1 ) );
		}

		override public function equals( obj: Object ): Boolean
		{
			if ( obj is PdfCrossReference )
			{
				var other: PdfCrossReference = PdfCrossReference( obj );
				return ( _refnum == other._refnum );
			}
			else
			{
				return false;
			}
		}

		public function get refnum(): int
		{
			return _refnum;
		}

		override public function hashCode(): int
		{
			return _refnum;
		}

		/**
		 * Writes PDF syntax to the OutputStream
		 */
		public function midSizeToPdf( midSize: int, os: IOutputStream ): void
		{
			assert_true( midSize >= 0, "midSize must be greater than 0" );
			os.writeInt( ByteBuffer.intToByte( type ) );

			while ( --midSize >= 0 )
				os.writeInt( ByteBuffer.intToByte( ( offset >>> ( 8 * midSize ) ) & 0xff ) );
			os.writeInt( ByteBuffer.intToByte( ( generation >>> 8 ) & 0xff ) );
			os.writeInt( ByteBuffer.intToByte( generation & 0xff ) );
		}

		/**
		 * Returns the PDF representation of this <CODE>PdfObject</CODE>.
		 */
		public function toPdf( os: IOutputStream ): void
		{
			var off: String = "0000000000" + offset.toString();
			off = off.substr( off.length - 10 );
			var gen: String = "00000" + generation.toString();
			gen = gen.substr( gen.length - 5 );
			off += " " + gen + ( generation == PdfWriter.GENERATION_MAX ? " f \n" : " n \n" );
			os.writeBytes( PdfWriter.getISOBytes( off ) );
		}
	}
}