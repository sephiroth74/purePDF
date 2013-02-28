/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfContents.as 240 2010-02-01 10:53:22Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 240 $ $LastChangedDate: 2010-02-01 05:53:22 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfContents.as $
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
	import flash.utils.ByteArray;
	
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.errors.BadPdfFormatError;

	public class PdfContents extends PdfStream
	{
		protected static const SAVESTATE: ByteArray = 	PdfWriter.getISOBytes("q\n").buffer;
		protected static const RESTORESTATE: ByteArray= PdfWriter.getISOBytes("Q\n").buffer;
		protected static const ROTATE90: ByteArray = 	PdfWriter.getISOBytes("0 1 -1 0 ").buffer;
		protected static const ROTATE180: ByteArray = 	PdfWriter.getISOBytes("-1 0 0 -1 ").buffer;
		protected static const ROTATE270: ByteArray = 	PdfWriter.getISOBytes("0 -1 1 0 ").buffer;
		protected static const ROTATEFINAL: ByteArray = PdfWriter.getISOBytes(" cm\n").buffer;
		
		public function PdfContents( under: PdfContentByte, content: PdfContentByte, text: PdfContentByte, secondContent: PdfContentByte, page: RectangleElement )
		{
			super();
			
			try
			{
				var out: ByteArray = null;
				streamBytes = new ByteArray();
				
				out = streamBytes;
				
				if( PdfDocument.compress )
				{
					compressed = true;
					compressionLevel = text.writer.compressionLevel;
				}
				
				var rotation: int = page.rotation;
				switch( rotation )
				{
					case 90:
						out.writeBytes( ROTATE90 );
						out.writeBytes( PdfWriter.getISOBytes( ByteBuffer.formatDouble( page.getTop() ) ).buffer );
						out.writeInt( ' '.charCodeAt(0) );
						out.writeInt( '0'.charCodeAt(0) );
						out.writeBytes( ROTATEFINAL );
						break;
					
					case 180:
						out.writeBytes( ROTATE180 );
						out.writeBytes( PdfWriter.getISOBytes( ByteBuffer.formatDouble( page.getRight() ) ).buffer );
						out.writeInt( ' '.charCodeAt(0) );
						out.writeBytes( PdfWriter.getISOBytes( ByteBuffer.formatDouble( page.getTop() ) ).buffer );
						out.writeBytes( ROTATEFINAL );
						break;
					
					case 270:
						out.writeBytes( ROTATE270 );
						out.writeByte( '0'.charCodeAt(0) );
						out.writeByte( ' '.charCodeAt(0) );
						out.writeBytes( PdfWriter.getISOBytes( ByteBuffer.formatDouble(page.getRight()) ).buffer );
						out.writeBytes( ROTATEFINAL );
						break;
				}
				
				if( under.size > 0 ){
					out.writeBytes( SAVESTATE );
					under.getInternalBuffer().writeTo( out );
					out.writeBytes( RESTORESTATE );
				}
				
				if( content.size > 0 ){
					out.writeBytes( SAVESTATE );
					content.getInternalBuffer().writeTo( out );
					out.writeBytes( RESTORESTATE );
				}
				
				if( text != null ){
					out.writeBytes( SAVESTATE );
					text.getInternalBuffer().writeTo( out );
					out.writeBytes( RESTORESTATE );
				}
				
				if( secondContent.size > 0 ){
					secondContent.getInternalBuffer().writeTo( out );
				}
				
				if( compressed )
					out.compress();
				
			} catch( e: Error )
			{
				throw new BadPdfFormatError(e);
			}
			
			put( PdfName.LENGTH, new PdfNumber( streamBytes.length ) );
			
			if( compressed )
				put( PdfName.FILTER, PdfName.FLATEDECODE );
		}
	}
}