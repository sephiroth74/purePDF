/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfString.as 334 2010-02-14 23:07:30Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 334 $ $LastChangedDate: 2010-02-14 18:07:30 -0500 (Sun, 14 Feb 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfString.as $
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
	import org.purepdf.pdf.interfaces.IOutputStream;
	import org.purepdf.utils.Bytes;

	public class PdfString extends PdfObject
	{
		protected var encoding: String = TEXT_PDFDOCENCODING;
		protected var hexWriting: Boolean;
		protected var objGen: int;
		protected var objNum: int = 0;
		protected var originalValue: String = null;
		protected var value: String = NOTHING;

		/**
		 * Create a new PdfString
		 * @param $value	String or Bytes
		 */
		public function PdfString( $value: *, $encoding: String = TEXT_PDFDOCENCODING )
		{
			super( STRING );
			encoding = $encoding;

			if ( $value is String )
			{
				value = $value;
			} else if ( $value is Bytes )
			{
				value = PdfEncodings.convertToString( $value, null );
				encoding = NOTHING;
			} else
			{
				throw new Error( "only string and bytes supported" );
			}
		}

		override public function getBytes(): Bytes
		{
			if ( bytes == null )
			{
				if ( encoding != null && encoding == TEXT_UNICODE && PdfEncodings.isPdfDocEncoding( value ) )
					bytes = PdfEncodings.convertToBytes( value, TEXT_PDFDOCENCODING );
				else
					bytes = PdfEncodings.convertToBytes( value, encoding );
			}
			return bytes;
		}

		public function isHexWriting(): Boolean
		{
			return hexWriting;
		}

		public function setEncoding( enc: String ): void
		{
			encoding = enc;
		}

		public function setHexWriting( hexWriting: Boolean ): PdfString
		{
			this.hexWriting = hexWriting;
			return this;
		}

		override public function toPdf( writer: PdfWriter, os: IOutputStream ): void
		{
			os.writeBytes( PdfContentByte.escapeByteArray( getBytes() ) );
		}

		override public function toString(): String
		{
			return value;
		}

		/**
		 * Returns the Unicode String value of this
		 */
		public function toUnicodeString(): String
		{
			if ( encoding != null && encoding.length != 0 )
				return value;
			getBytes();
			if ( bytes.length >= 2 && bytes[0] == -2 && bytes[1] == -1 )
				return PdfEncodings.convertToString( bytes, PdfObject.TEXT_UNICODE );
			else
				return PdfEncodings.convertToString( bytes, PdfObject.TEXT_PDFDOCENCODING );
		}

		/**
		 * Decrypt an encrypted PdfString
		 */
		internal function decrypt( reader: PdfReader ): void
		{
			trace( 'PdfString.decrypt not yet implemented' );
		/*
		   var decrypt: PdfEncryption = reader.decrypt;
		   if (decrypt != null)
		   {
		   throw new NonImplementatioError();
		   originalValue = value;
		   decrypt.setHashKey(objNum, objGen);
		   bytes = PdfEncodings.convertToBytes(value, null);
		   bytes = decrypt.decryptByteArray(bytes);
		   value = PdfEncodings.convertToString(bytes, null);
		   }
		 */
		}

		internal function setObjNum( objNum: int, objGen: int ): void
		{
			this.objNum = objNum;
			this.objGen = objGen;
		}
	}
}