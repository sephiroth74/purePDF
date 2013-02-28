/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: InputMeta.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
 * $Author Alessandro Crugnola $
 * $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/codecs/wmf/InputMeta.as $
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

package org.purepdf.codecs.wmf
{
	import flash.errors.IOError;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.io.InputStream;
	import org.purepdf.utils.Utilities;

	public class InputMeta
	{

		protected var input: InputStream;
		protected var length: int;

		public function InputMeta( input: InputStream )
		{
			this.input = input;
			length = 0;
		}

		public function getLength(): int
		{
			return length;
		}
		
		public function getPosition(): int
		{
			return this.input.position;
		}
		
		public function getAvailable(): int
		{
			return this.input.available;
		}

		/**
		 * @throws IOError
		 */
		public function readByte(): int
		{
			++length;
			return input.readUnsignedByte() & 0xff;
		}

		/**
		 * @throws IOError
		 */
		public function readColor(): RGBColor
		{
			var red: int = readByte();
			var green: int = readByte();
			var blue: int = readByte();
			readByte();
			return new RGBColor( red, green, blue );
		}

		/**
		 * @throws IOError
		 */
		public function readInt(): int
		{
			length += 4;
			var k1: int = input.readUnsignedByte();
			if ( k1 < 0 )
				return 0;
			var k2: int = input.readUnsignedByte() << 8;
			var k3: int = input.readUnsignedByte() << 16;
			var k4: int = input.readUnsignedByte() << 24;
			return k1 + k2 + k3 + k4;
		}

		/**
		 * @throws IOError
		 */
		public function readShort(): int
		{
			var k: int = readWord();
			if ( k > 0x7fff )
				k -= 0x10000;
			return k;
		}

		/**
		 * @throws IOError
		 */
		public function readWord(): int
		{
			length += 2;
			var k1: int = input.readUnsignedByte();
			if ( k1 < 0 )
				return 0;
			return ( k1 + ( input.readUnsignedByte() << 8 ) ) & 0xffff;
		}

		/**
		 * @throws IOError
		 */
		public function skip( len: int ): void
		{
			length += len;
			input.skip( len );
		}
	}
}