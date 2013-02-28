/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: HeaderFooter.as 362 2010-05-05 16:53:53Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 362 $ $LastChangedDate: 2010-05-05 12:53:53 -0400 (Wed, 05 May 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/HeaderFooter.as $
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
package org.purepdf.elements
{
	import org.purepdf.Font;
	import org.purepdf.utils.assert_true;
	import org.purepdf.utils.pdf_core;

	public class HeaderFooter extends RectangleElement
	{
		use namespace pdf_core;
		
		private var _numbered: Boolean;
		private var _before: Phrase;
		private var _after: Phrase;
		private var _pageN: int = 0;
		private var _alignment: int;
		
		/**
		 * Header/Footer
		 * If both before and after are passed then numbered is forced to true
		 * 
		 * @throws AssertionError
		 */
		public function HeaderFooter( before: Phrase, after: Phrase = null, numbered: Boolean = true )
		{
			super(0,0,0,0);
			assert_true( before != null, "before Phrase can't be null");
			
			border = TOP | BOTTOM;
			borderWidth = 1;
			
			this._before = before;
			this._after = after;
			this._numbered = after != null ? true : numbered;
		}
		
		public function get paragraph(): Paragraph
		{
			var p: Paragraph = Paragraph.fromChunk( null, _before.leading );
			p.add( _before );
			if( _numbered )
				p.addSpecial( new Chunk( _pageN.toString(), _before.font ) );
			
			if( _after != null )
				p.addSpecial( _after );
			
			p.alignment = _alignment;
			return p;
		}
		
		public function get alignment():int
		{
			return _alignment;
		}

		public function set alignment(value:int):void
		{
			_alignment = value;
		}

		public function get pageNumber():int
		{
			return _pageN;
		}

		public function set pageNumber(value:int):void
		{
			_pageN = value;
		}

		public function get numbered():Boolean
		{
			return _numbered;
		}

	}
}