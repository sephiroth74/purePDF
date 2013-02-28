/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfObject.as 350 2010-02-24 23:57:29Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 350 $ $LastChangedDate: 2010-02-24 18:57:29 -0500 (Wed, 24 Feb 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfObject.as $
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
	import org.purepdf.pdf.interfaces.IDisposable;
	import org.purepdf.pdf.interfaces.IOutputStream;
	import org.purepdf.utils.Bytes;

	public class PdfObject extends ObjectHash implements IDisposable
	{
		public static const ARRAY: int = 5;
		public static const BOOLEAN: int = 1;
		public static const DICTIONARY: int = 6;
		public static const INDIRECT: int = 10;
		public static const NAME: int = 4;

		public static const NOTHING: String = "";
		public static const NULL: int = 8;
		public static const NUMBER: int = 2;
		public static const STREAM: int = 7;
		public static const STRING: int = 3;
		public static const TEXT_PDFDOCENCODING: String = "PDF";
		public static const TEXT_UNICODE: String = "UnicodeBig";

		protected var bytes: Bytes;
		protected var indRef: PRIndirectReference;
		protected var type: int;

		public function PdfObject( $type: int )
		{
			super();
			type = $type;
		}

		/**
		 * Whether this object can be contained in an object stream.
		 *
		 * PdfObjects of type STREAM OR INDIRECT can not be contained in an
		 * object stream.
		 *
		 * @return <CODE>true</CODE> if this object can be in an object stream.
		 */
		public function canBeInObjStm(): Boolean
		{
			switch ( type )
			{
				case NULL:
				case BOOLEAN:
				case NUMBER:
				case STRING:
				case NAME:
				case ARRAY:
				case DICTIONARY:
					return true;

				case STREAM:
				case INDIRECT:
				default:
					return false;
			}
		}

		public function dispose(): void
		{
			indRef = null;
			bytes = null;
		}

		public function getBytes(): Bytes
		{
			return bytes;
		}

		public function getIndRef(): PRIndirectReference
		{
			return indRef;
		}

		public function getType(): int
		{
			return type;
		}

		public function isArray(): Boolean
		{
			return type == ARRAY;
		}

		public function isBoolean(): Boolean
		{
			return type == BOOLEAN;
		}

		public function isDictionary(): Boolean
		{
			return type == DICTIONARY;
		}

		public function isIndirect(): Boolean
		{
			return type == INDIRECT;
		}

		public function isName(): Boolean
		{
			return type == NAME;
		}

		public function isNull(): Boolean
		{
			return type == NULL;
		}

		public function isNumber(): Boolean
		{
			return type == NUMBER;
		}

		/**
		 * Checks if this PdfObject is of the type PdfStream
		 */
		public function isStream(): Boolean
		{
			return type == STREAM;
		}

		public function isString(): Boolean
		{
			return type == STRING;
		}

		/**
		 * Set the indirect reference
		 */
		public function setIndRef( indRef: PRIndirectReference ): void
		{
			this.indRef = indRef;
		}

		public function toPdf( writer: PdfWriter, os: IOutputStream ): void
		{
			if ( bytes != null )
			{
				os.writeBytes( bytes );
			}
		}

		public function toString(): String
		{
			if ( bytes == null )
				return "[PDFObject: null]";
			return PdfEncodings.convertToString( bytes, null );
		}

		protected function setContent( content: String ): void
		{
			bytes = PdfEncodings.convertToBytes( content, null );
		}
	}
}