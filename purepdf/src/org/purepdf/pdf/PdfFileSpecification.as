/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfFileSpecification.as 394 2011-01-14 18:48:14Z alessandro.crugnola@gmail.com $
 * $Author Alessandro Crugnola $
 * $Rev: 394 $ $LastChangedDate: 2011-01-14 13:48:14 -0500 (Fri, 14 Jan 2011) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfFileSpecification.as $
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
	
	import org.purepdf.io.InputStream;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.pdf_core;

	public class PdfFileSpecification extends PdfDictionary
	{
		use namespace pdf_core;
		
		protected var ref: PdfIndirectReference;
		protected var writer: PdfWriter;

		public function PdfFileSpecification()
		{
			super( PdfName.FILESPEC );
		}

		/**
		 * Adds a description for the file that is specified here.
		 * @param description	some text
		 * @param unicode		if true, the text is added as a unicode string
		 */
		public function addDescription( description: String, unicode: Boolean ): void
		{
			put( PdfName.DESC, new PdfString( description, unicode ? PdfObject.TEXT_UNICODE : PdfObject.TEXT_PDFDOCENCODING ) );
		}

		/**
		 * Gets the indirect reference to this file specification.
		 * Multiple invocations will retrieve the same value.
		 * @throws IOException on error
		 * @return the indirect reference
		 */
		public function get reference(): PdfIndirectReference
		{
			if ( ref != null )
				return ref;
			ref = writer.addToBody( this ).indirectReference;
			return ref;
		}

		public function setUnicodeFileName( filename: String, unicode: Boolean ): void
		{
			put( PdfName.UF, new PdfString( filename, unicode ? PdfObject.TEXT_UNICODE : PdfObject.TEXT_PDFDOCENCODING ) );
		}
		
		
		/**
		 * Creates a file specification for an external file.
		 * @param writer the <CODE>PdfWriter</CODE>
		 * @param filePath the file path
		 * @return the file specification
		 */
		public static function fileExtern( writer: PdfWriter, filePath: String ): PdfFileSpecification
		{
			var fs: PdfFileSpecification = new PdfFileSpecification();
			fs.writer = writer;
			fs.put( PdfName.F, new PdfString( filePath ) );
			fs.setUnicodeFileName( filePath, false );
			return fs;
		}

		public static function fileEmbedded( writer: PdfWriter, fileDisplay: String, fileStore: ByteArray, compress: Boolean, mimeType: String = null, fileParameter: PdfDictionary = null ): PdfFileSpecification
		{
			return _fileEmbedded( writer, fileDisplay, fileStore, mimeType, fileParameter, compress ? PdfStream.BEST_COMPRESSION : PdfStream.NO_COMPRESSION );
		}
		
		public static function fileEmbedded2( writer: PdfWriter, filePath: String, fileStore: ByteArray ): PdfFileSpecification
		{
			return fileEmbedded( writer, filePath, fileStore, true );
		}

		private static function _fileEmbedded( writer: PdfWriter, fileDisplay: String, fileStore: ByteArray, mimeType: String, fileParameter: PdfDictionary, compressionLevel: int ): PdfFileSpecification
		{
			var fs: PdfFileSpecification = new PdfFileSpecification();
			fs.writer = writer;
			fs.put( PdfName.F, new PdfString( fileDisplay ) );
			fs.setUnicodeFileName( fileDisplay, false );
			var stream: PdfEFStream;
			var ref: PdfIndirectReference;
			stream = new PdfEFStream( new Bytes( fileStore ) );
			stream.put( PdfName.TYPE, PdfName.EMBEDDEDFILE );
			stream.flateCompress( compressionLevel );
			var param: PdfDictionary = new PdfDictionary();
			if ( fileParameter != null )
			{
				param.merge( fileParameter );
			}

			param.put( PdfName.SIZE, new PdfNumber( stream.getRawLength() ) );
			stream.put( PdfName.PARAMS, param );

			if ( mimeType != null )
				stream.put( PdfName.SUBTYPE, new PdfName( mimeType ) );

			ref = writer.addToBody( stream ).indirectReference;
			var f: PdfDictionary = new PdfDictionary();
			f.put( PdfName.F, ref );
			f.put( PdfName.UF, ref );
			fs.put( PdfName.EF, f );
			return fs;
		}
	}
}