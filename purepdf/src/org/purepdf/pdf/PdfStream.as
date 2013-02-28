/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfStream.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfStream.as $
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
	import flash.errors.IOError;
	import flash.utils.ByteArray;
	
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.pdf.interfaces.IOutputStream;
	import org.purepdf.utils.Bytes;
	
	
	public class PdfStream extends PdfDictionary
	{
		public static const NO_COMPRESSION: int = 0;
		public static const BEST_COMPRESSION: int = 9;
		
		protected static const STARTSTREAM: Bytes = PdfWriter.getISOBytes("stream\n");
		protected static const ENDSTREAM: Bytes = 	PdfWriter.getISOBytes("\nendstream");
		protected static const SIZESTREAM: int = STARTSTREAM.length + ENDSTREAM.length;
		
		protected var compressed: Boolean = false;
		protected var compressionLevel: int = BEST_COMPRESSION;
		protected var streamBytes: ByteArray = null;
		protected var inputStream: ByteArray;
		protected var ref: PdfIndirectReference;
		protected var inputStreamLength: int = -1;
		protected var writer: PdfWriter;
		protected var rawLength: int;
		
		public function PdfStream( $byte: Bytes = null )
		{
			super();
			type = STREAM;
			
			if( $byte != null )
			{
				bytes = $byte;
				rawLength = bytes.length;
				put( PdfName.LENGTH, new PdfNumber( bytes.length ) );
			}
		}
		
		public function flateCompress( compressionLevel: int ): void
		{
			if( !PdfDocument.compress )
				return;
			
			if( compressed )
				return;
			
			var filter: PdfObject = PdfReader.getPdfObject( getValue( PdfName.FILTER ) );
			if (filter != null) 
			{
				if (filter.isName()) {
					if (PdfName.FLATEDECODE.equals(filter))
						return;
				}
				else if (filter.isArray()) {
					if( PdfArray(filter).contains( PdfName.FLATEDECODE ) )
						return;
				}
				else {
					throw new RuntimeError("stream could not be compressed. filter is not a name or array");
				}
			}

			try {
				// compress
				
				var zip: ByteArray = new ByteArray();
				
				if (streamBytes != null)
					zip.writeBytes( streamBytes );
				else
					zip.writeBytes( bytes.buffer );
				zip.compress();
				
				streamBytes = zip;
				bytes = null;
				
				put( PdfName.LENGTH, new PdfNumber( streamBytes.length ) );
				if (filter == null) 
				{
					put( PdfName.FILTER, PdfName.FLATEDECODE );
				} else 
				{
					var filters: PdfArray = new PdfArray( filter );
					filters.add( PdfName.FLATEDECODE );
					put( PdfName.FILTER, filters );
				}
				compressed = true;
			} catch( ioe: IOError )
			{
				throw new ConversionError( ioe );
			}
		}
		
		override public function toPdf( writer: PdfWriter, os: IOutputStream ): void
		{
			if( inputStream != null && compressed )
				put( PdfName.FILTER, PdfName.FLATEDECODE );
			
			var crypto: PdfEncryption = null;
			if( writer != null )
				crypto = writer.getEncryption();
			
			if( crypto != null )
			{
				var filter: PdfObject = getValue( PdfName.FILTER );
				if( filter != null ) 
				{
					if( PdfName.CRYPT.equals( filter ) )
						crypto = null;
					else if( filter.isArray() )
					{
						var a: PdfArray = PdfArray(filter);
						if( !a.isEmpty && PdfName.CRYPT.equals( a.getPdfObject(0) ) )
							crypto = null;
					}
				}
			}
			
			var nn: PdfObject = getValue( PdfName.LENGTH );
			
			if( crypto != null && nn != null && nn.isNumber() )
			{
				var sz: int = PdfNumber(nn).intValue();
				put( PdfName.LENGTH, new PdfNumber( crypto.calculateStreamSize(sz) ) );
				superToPdf( writer, os );
				put( PdfName.LENGTH, nn );				
			} else
			{
				superToPdf( writer, os );
			}
			
			os.writeBytes( STARTSTREAM, 0, STARTSTREAM.length );
			
			if( inputStream != null )
			{
				rawLength = 0;
				var fout: IOutputStream = os;
				var counter: int = 0;
				
				var buf: Bytes = new Bytes();
				while( true )
				{
					inputStream.readBytes( buf.buffer, 0, 4192 );
	
					if( buf.length <= 0 )
					{
						break;
					}
					
					fout.writeBytes( buf, 0, buf.length );
					counter += buf.length;
					rawLength += buf.length;
				}
				
				inputStreamLength = counter;
			} else
			{
				if( crypto != null && !crypto.embeddedFilesOnly ) 
				{
					var b: Bytes;
					
					if( streamBytes != null ) 
					{
						b = crypto.encryptByteArray( new Bytes( streamBytes ) );
					}
					else 
					{
						b = crypto.encryptByteArray(bytes);
					}
					os.writeBytes( b );
				} else if( streamBytes != null )
				{
					os.writeByteArray( streamBytes );
				} else
				{
					os.writeBytes( bytes, 0, bytes.length );
				}
			}
			
			os.writeBytes( ENDSTREAM, 0, ENDSTREAM.length );
		}
		
		public function getRawLength(): int
		{
			return rawLength;
		}
		
		protected function superToPdf( writer: PdfWriter, os: IOutputStream ): void
		{
			super.toPdf( writer, os );
		}
		
		override public function toString(): String
		{
			if( getValue( PdfName.TYPE ) == null )
				return "stream";
			return "Stream of type: " + getValue( PdfName.TYPE );
		}
	}
}