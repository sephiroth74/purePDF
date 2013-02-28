/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfVersion.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfVersion.as $
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
	
	import org.purepdf.utils.Bytes;
	import org.purepdf.io.OutputStreamCounter;

	public class PdfVersion extends ObjectHash
	{

		public static const PDF_VERSION_1_2: PdfName = new PdfName( "1.2" );
		public static const PDF_VERSION_1_3: PdfName = new PdfName( "1.3" );
		public static const PDF_VERSION_1_4: PdfName = new PdfName( "1.4" );
		public static const PDF_VERSION_1_5: PdfName = new PdfName( "1.5" );
		public static const PDF_VERSION_1_6: PdfName = new PdfName( "1.6" );
		public static const PDF_VERSION_1_7: PdfName = new PdfName( "1.7" );
		
		public static const VERSION_1_2: String = '2';
		public static const VERSION_1_3: String = '3';
		public static const VERSION_1_4: String = '4';
		public static const VERSION_1_5: String = '5';
		public static const VERSION_1_6: String = '6';
		public static const VERSION_1_7: String = '7';
		
		
		public static const HEADER: Vector.<Bytes> = Vector.<Bytes>( [ PdfWriter.getISOBytes( "\n" ), PdfWriter.getISOBytes( "%PDF-" ), PdfWriter
			.getISOBytes( "\n%\u00e2\u00e3\u00cf\u00d3\n" ) ] );
		protected var appendMode: Boolean = false;
		protected var catalog_version: PdfName = null;
		protected var headerWasWritten: Boolean = false;
		protected var extensions: PdfDictionary = null;
		protected var header_version: String = VERSION_1_4;

		public function addToCatalog( catalog: PdfDictionary ): void
		{
			if( catalog_version != null )
				catalog.put( PdfName.VERSION, catalog_version );
			
			if( extensions != null )
				catalog.put( PdfName.EXTENSIONS, extensions );
		}

		public function getVersionAsByteArray( version: String ): Bytes
		{
			return PdfWriter.getISOBytes( getVersionAsName( version ).toString().substring( 1 ) );
		}

		public function getVersionAsName( version: String ): PdfName
		{
			switch ( version )
			{
				case VERSION_1_2:
					return PDF_VERSION_1_2;
					
				case VERSION_1_3:
					return PDF_VERSION_1_3;
					
				case VERSION_1_4:
					return PDF_VERSION_1_4;
					
				case VERSION_1_5:
					return PDF_VERSION_1_5;

				case VERSION_1_6:
					return PDF_VERSION_1_6;
				
				case VERSION_1_7:
					return PDF_VERSION_1_7;
					
				default:
					return PDF_VERSION_1_4;
			}
		}

		public function setPdfVersion( value: String ): void
		{
			if ( headerWasWritten || appendMode )
			{
				setPdfVersionName( getVersionAsName( value ) );
			}
			else
			{
				header_version = value;
			}
		}

		public function writeHeader( os: OutputStreamCounter ): void
		{
			if( appendMode )
			{
				os.writeBytes( HEADER[0], 0, HEADER[0].length );
			} else {
				os.writeBytes( HEADER[ 1 ], 0, HEADER[ 1 ].length );
				os.writeBytes( getVersionAsByteArray( header_version ) );
				os.writeBytes( HEADER[ 2 ], 0, HEADER[ 2 ].length );
				headerWasWritten = true;
			}
		}

		private function setPdfVersionName( value: PdfName ): void
		{
			if ( catalog_version == null || catalog_version.compareTo( value ) < 0 )
				this.catalog_version = value;
		}
		
		internal function setAtLeastPdfVersion( version: String ): void
		{
			if( version.charCodeAt(0) > header_version.charCodeAt(0) )
			{
				setPdfVersion( version );
			}
		}
	}
}