/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PRStream.as 350 2010-02-24 23:57:29Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 350 $ $LastChangedDate: 2010-02-24 18:57:29 -0500 (Wed, 24 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PRStream.as $
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
	public class PRStream extends PdfStream
	{
		protected var _reader: PdfReader;
		protected var _offset: int;
		protected var _length: int;
		protected var objNum: int = 0;
		protected var objGen: int = 0;
		
		public function PRStream()
		{
			super();
		}
		
		override public function dispose(): void
		{
			super.dispose();
			_reader = null;
		}
		
		public static function fromReader( reader: PdfReader, offset: int ): PRStream
		{
			var s: PRStream = new PRStream();
			s._reader = reader;
			s._offset = offset;
			return s;
		}
		
		public static function fromPRStream( stream: PRStream, newDic: PdfDictionary ): PRStream
		{
			var res: PRStream = new PRStream();
			res._reader = stream.reader;
			res._offset = stream.offset;
			res._length = stream.length;
			res.compressed = stream.compressed;
			res.compressionLevel = stream.compressionLevel;
			res.streamBytes = stream.streamBytes;
			res.bytes = stream.bytes;
			res.objNum = stream.objNum;
			res.objGen = stream.objGen;
			if (newDic != null)
				res.putAll(newDic);
			else
				res.hashMap.putAll(stream.hashMap);
			return res;
		}
		
		public function getObjGen(): int
		{
			return objGen;
		}
		
		public function getObjNum(): int
		{
			return objNum;
		}
		
		public function setObjNum( objNum: int, objGen: int ): void
		{
			this.objNum = objNum;
			this.objGen = objGen;
		}

		public function set reader(value:PdfReader):void
		{
			_reader = value;
		}

		public function get reader():PdfReader
		{
			return _reader;
		}

		public function get offset():int
		{
			return _offset;
		}

		public function get length():int
		{
			return _length;
		}

		public function set length(value:int):void
		{
			_length = value;
			put( PdfName.LENGTH, new PdfNumber(value));
		}

	}
}