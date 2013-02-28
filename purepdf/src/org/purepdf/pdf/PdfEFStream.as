/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfEFStream.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfEFStream.as $
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
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.io.OutputStreamCounter;
	import org.purepdf.pdf.interfaces.IOutputStream;
	import org.purepdf.utils.Bytes;

	public class PdfEFStream extends PdfStream
	{
		public function PdfEFStream( $byte: Bytes = null )
		{
			super( $byte );
		}

		override public function toPdf( writer: PdfWriter, os: IOutputStream ): void
		{
			if ( inputStream != null && compressed )
				put( PdfName.FILTER, PdfName.FLATEDECODE );
			var crypto: PdfEncryption = null;

			if ( writer != null )
				crypto = writer.getEncryption();

			if ( crypto != null )
			{
				var filter: PdfObject = getValue( PdfName.FILTER );
				if ( filter != null )
				{
					if ( PdfName.CRYPT.equals( filter ) )
						crypto = null;
					else if ( filter.isArray() )
					{
						var a: PdfArray = PdfArray( filter );
						if ( !a.isEmpty && PdfName.CRYPT.equals( a.getPdfObject( 0 ) ) )
							crypto = null;
					}
				}
			}

			if ( crypto != null && crypto.embeddedFilesOnly )
			{
				var afilter: PdfArray = new PdfArray();
				var decodeparms: PdfArray = new PdfArray();
				var crypt: PdfDictionary = new PdfDictionary();
				crypt.put( PdfName.NAME, PdfName.STDCF );
				afilter.add( PdfName.CRYPT );
				decodeparms.add( crypt );
				if ( compressed )
				{
					afilter.add( PdfName.FLATEDECODE );
					decodeparms.add( new PdfNull() );
				}
				put( PdfName.FILTER, afilter );
				put( PdfName.DECODEPARMS, decodeparms );
			}

			var nn: PdfObject = getValue( PdfName.LENGTH );
			if ( crypto != null && nn != null && nn.isNumber() )
			{
				var sz: int = PdfNumber( nn ).intValue();
				put( PdfName.LENGTH, new PdfNumber( crypto.calculateStreamSize( sz ) ) );
				superToPdf( writer, os );
				put( PdfName.LENGTH, nn );
			} else
			{
				superToPdf( writer, os );
			}

			os.writeBytes( STARTSTREAM );
			if ( inputStream != null )
			{
				throw new NonImplementatioError();
			} else
			{
				if ( crypto == null )
				{
					if ( streamBytes != null )
						os.writeByteArray( streamBytes );
					else
						os.writeBytes( bytes );
				} else
				{
					var b: Bytes;
					if ( streamBytes != null )
					{
						b = crypto.encryptByteArray( new Bytes( streamBytes ) );
					} else
					{
						b = crypto.encryptByteArray( bytes );
					}
					os.writeBytes( b );
				}
			}
			os.writeBytes( ENDSTREAM );
		}
	}
}