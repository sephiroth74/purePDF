/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: StreamFont.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/StreamFont.as $
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
package org.purepdf.pdf.fonts
{
	import org.purepdf.errors.DocumentError;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfNumber;
	import org.purepdf.pdf.PdfStream;
	import org.purepdf.utils.Bytes;

	public class StreamFont extends PdfStream
	{
		
		public function StreamFont( contents: Bytes, len: int )
		{
			bytes = contents;
			put( PdfName.LENGTH, new PdfNumber( len ) );
		}
		/**
		 *
		 * @throws DocumentError
		 */
		public static function create( contents: Bytes, lengths: Vector.<int>, compressionLevel: int ): StreamFont
		{
			var s: StreamFont = new StreamFont( contents, contents.length );
			try
			{
				for ( var k: int = 0; k < lengths.length; ++k )
				{
					s.put( new PdfName( "Length" + ( k + 1 ) ), new PdfNumber( lengths[ k ] ) );
				}

				s.flateCompress( compressionLevel );
			}
			catch ( e: Error )
			{
				throw new DocumentError( e );
			}
			return s;
		}
		
		/**
		 * Generates the PDF stream for a font.
		 * @param contents the content of a stream
		 * @param subType the subtype of the font.
		 * @param compressionLevel	the compression level of the Stream
		 * @throws DocumentError
		 */
		public static function create2( contents: Bytes, subType: String, compressionLevel: int ): StreamFont
		{
			var s: StreamFont = new StreamFont( contents, contents.length );
			try 
			{
				if( subType != null )
					s.put( PdfName.SUBTYPE, new PdfName( subType ) );
				s.flateCompress( compressionLevel );
			}
			catch( e: Error )
			{
				throw new DocumentError( e );
			}
			return s;
		}
	}
}