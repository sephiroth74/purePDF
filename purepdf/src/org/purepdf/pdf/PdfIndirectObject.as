/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfIndirectObject.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfIndirectObject.as $
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
	
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.interfaces.IOutputStream;
	import org.purepdf.utils.Bytes;

	public class PdfIndirectObject extends ObjectHash
	{
		protected var number: int;
		
		protected var generation: int = 0;
		
		private static const STARTOBJ: Bytes = 	PdfWriter.getISOBytes(" obj\n");
		private static const ENDOBJ: Bytes = 	PdfWriter.getISOBytes("\nendobj\n");
		private static const SIZEOBJ: int = STARTOBJ.length + ENDOBJ.length;
		
		private var object: PdfObject;
		private var writer: PdfWriter;
		
		/**
		 * Constructs a <CODE>PdfIndirectObject</CODE>.
		 *
		 * @param		number			the object number
		 * @param		generation		the generation number
		 * @param		object			the direct object
		 */
		
		function PdfIndirectObject( $number: int, $generation: int, $object: PdfObject, $writer: PdfWriter )
		{
			writer = $writer;
			number = $number;
			generation = $generation;
			object = $object;
			
			var crypto: PdfEncryption = null;
			if (writer != null)
				crypto = writer.getEncryption();
			
			if (crypto != null)
			{
				throw new NonImplementatioError();
			}
		}
		
		public function get indirectReference(): PdfIndirectReference
		{
			return new PdfIndirectReference( 0, number, generation );
		}
		
		/**
		 * Writes efficiently to a stream
		 */
		public function writeTo( os: IOutputStream ): void
		{
			os.writeBytes( PdfWriter.getISOBytes( number.toString() ) );
			os.writeInt( 32 );
			os.writeBytes( PdfWriter.getISOBytes( generation.toString() ));
			os.writeBytes( STARTOBJ );
			object.toPdf( writer, os );
			os.writeBytes( ENDOBJ );
		}
	}
}