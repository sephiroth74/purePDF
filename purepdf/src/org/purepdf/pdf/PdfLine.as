/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfLine.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfLine.as $
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
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.ListItem;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.utils.iterators.VectorIterator;
	import org.purepdf.utils.pdf_core;

	public class PdfLine extends ObjectHash
	{
		use namespace pdf_core;
		
		protected var _alignment: int = 0;
		protected var _height: Number = 0;
		protected var _left: Number = 0;
		protected var _listSymbol: Chunk = null;
		protected var _right: Number = 0;
		protected var _width: Number = 0;
		protected var _isRTL: Boolean = false;
		protected var line: Vector.<PdfChunk>;
		protected var _newlineSplit: Boolean = false;
		protected var _originalWidth: Number = 0;
		protected var symbolIndent: Number = 0;

		public function PdfLine( $left: Number, $right: Number, $alignment: int, $height: Number )
		{
			_left = $left;
			_width = $right - $left;
			_originalWidth = _width;
			_alignment = $alignment;
			_height = $height;
			line = new Vector.<PdfChunk>();
		}
		
		/**
		 * Creates a PdfLine object.
		 * @param left				the left offset
		 * @param originalWidth		the original width of the line
		 * @param remainingWidth	bigger than 0 if the line isn't completely filled
		 * @param alignment			the alignment of the line
		 * @param newlineSplit		was the line splitted (or does the paragraph end with this line)
		 * @param line				an array of PdfChunk objects
		 * @param isRTL				do you have to read the line from Right to Left?
		 */

		public function get isRTL():Boolean
		{
			return _isRTL;
		}

		public function get originalWidth():Number
		{
			return _originalWidth;
		}

		public static function create( left: Number, originalWidth: Number, remainingWidth: Number, alignment: int, newlineSplit: Boolean
			, line: Vector.<PdfChunk>, isRTL: Boolean ): PdfLine
		{
			var r: PdfLine = new PdfLine( 0, 0, 0, 0 );
			r._left = left;
			r._originalWidth = originalWidth;
			r._width = remainingWidth;
			r._alignment = alignment;
			r.line = line;
			r._newlineSplit = newlineSplit;
			r._isRTL = isRTL;
			return r;
		}
		
		public function iterator(): Iterator
		{
			return new VectorIterator( Vector.<Object>( line ) );
		}

		public function getChunk( idx: int ): PdfChunk
		{
			if( idx < 0 || idx >= line.length )
				return null;
			return PdfChunk( line[idx] );
		}
		
		public function get ascender(): Number
		{
			var result: Number = 0;
			for( var k: int = 0; k < line.length; ++k )
			{
				var ck: PdfChunk = line[k] as PdfChunk;
				if( ck.isImage() )
					result = Math.max( result, ck.image.scaledHeight + ck.imageOffsetY );
				else {
					var font: PdfFont = ck.font;
					result = Math.max( result, font.font.getFontDescriptor( BaseFont.ASCENT, font.size ));
				}
			}
			return result;
		}
		
		public function get descender(): Number
		{
			var result: Number = 0;
			
			for( var k: int = 0; k < line.length; ++k )
			{
				var ck: PdfChunk = line[k] as PdfChunk;
				if( ck.isImage() )
					result = Math.min(result, ck.imageOffsetY );
				else {
					var font: PdfFont = ck.font;
					result = Math.min( result, font.font.getFontDescriptor(BaseFont.DESCENT, font.size ) );
				}
			}
			return result;
		}
		
		/**
		 * Gets the index of the last <CODE>PdfChunk</CODE> with metric attributes
		 */
		public function get lastStrokeChunk(): int
		{
			var lastIdx: int = line.length - 1;
			for (; lastIdx >= 0; --lastIdx)
			{
				if( line[lastIdx].isStroked())
					break;
			}
			return lastIdx;
		}
		
		
		public function get alignment(): int
		{
			return _alignment;
		}


		public function get hasToBeJustified(): Boolean
		{
			return ( ( _alignment == Element.ALIGN_JUSTIFIED || _alignment == Element.ALIGN_JUSTIFIED_ALL ) && _width != 0 );
		}
		
		public function resetAlignment(): void
		{
			if( _alignment == Element.ALIGN_JUSTIFIED )
				_alignment = Element.ALIGN_LEFT;
		}

		public function get height(): Number
		{
			return _height;
		}

		public function get isNewlineSplit(): Boolean
		{
			return _newlineSplit && ( alignment != Element.ALIGN_JUSTIFIED_ALL );
		}

		public function get left(): Number
		{
			return _left;
		}


		public function get listIndent(): Number
		{
			return symbolIndent;
		}
		
		/**
		 * Returns the length of a line in UTF32 characters
		 */
		public function get lengthUtf32(): int
		{
			var total: int = 0;

			for ( var i: Iterator = new VectorIterator( Vector.<Object>( line ) ); i.hasNext();  )
			{
				total += PdfChunk( i.next() ).lengthUtf32;
			}
			return total;
		}

		public function get listSymbol(): Chunk
		{
			return _listSymbol;
		}
		
		public function set listItem( value: ListItem ): void
		{
			_listSymbol = value.listSymbol;
			symbolIndent = value.indentationLeft;
		}

		public function get right(): Number
		{
			return _right;
		}

		public function get size(): int
		{
			return line.length;
		}

		public function toString(): String
		{
			var tmp: String = "";

			for ( var i: int = 0; i < line.length; ++i )
				tmp += line[ i ].toString();

			return tmp;
		}
		
		/**
		 * Gets the difference between the "normal" leading and the maximum
		 * size (for instance when there are images in the chunk).
		 */
		public function getMaxSize(): Vector.<Number>
		{
			var normal_leading: Number = 0;
			var image_leading: Number = -10000;
			var chunk: PdfChunk;
			for( var k: int = 0; k < line.length; ++k )
			{
				chunk = line[k];
				if( !chunk.isImage() )
					normal_leading = Math.max( chunk.font.size, normal_leading );
				else
					image_leading = Math.max( chunk.image.scaledHeight + chunk.imageOffsetY, image_leading );
			}
			return Vector.<Number>([normal_leading, image_leading]);
		}

		public function get widthLeft(): Number
		{
			return _width;
		}

		internal function add( chunk: PdfChunk ): PdfChunk
		{
			if ( chunk == null || chunk.toString() == "" )
			{
				return null;
			}

			// we split the chunk to be added
			var overflow: PdfChunk = chunk.split( _width );
			_newlineSplit = ( chunk.isNewlineSplit() || overflow == null );

			if ( chunk.isTab() )
			{
				var tab: Vector.<Object> = chunk.getAttribute( Chunk.TAB ) as Vector.<Object>;
				var tabPosition: Number = Number( tab[ 1 ] );
				var newline: Boolean = tab[ 2 ];

				if ( newline && tabPosition < originalWidth - _width )
					return chunk;

				_width = originalWidth - tabPosition;
				chunk.adjustLeft( _left );
				addToLine( chunk );
			}
			else if ( chunk.length > 0 || chunk.isImage() )
			{
				if ( overflow != null )
					chunk.trimLastSpace();
				_width -= chunk.width;
				addToLine( chunk );
			}
			else if ( line.length < 1 )
			{
				chunk = overflow;
				overflow = chunk.truncate( _width );
				_width -= chunk.width;

				if ( chunk.length > 0 )
				{
					addToLine( chunk );
					return overflow;
				}
				else
				{
					if ( overflow != null )
						addToLine( overflow );
					return null;
				}
			}
			else
			{
				_width += ( line[ line.length - 1 ] ).trimLastSpace();
			}
			return overflow;
		}

		internal function set extraIndent( extra: Number ): void
		{
			_left += extra;
			_width -= extra;
		}

		pdf_core function get indentLeft(): Number
		{
			if ( _isRTL )
			{
				switch ( alignment )
				{
					case Element.ALIGN_LEFT:
						return _left + _width;
					case Element.ALIGN_CENTER:
						return _left + ( _width / 2 );
					default:
						return _left;
				}
			}
			else if ( separatorCount == 0 )
			{
				switch ( alignment )
				{
					case Element.ALIGN_RIGHT:
						return _left + _width;
					case Element.ALIGN_CENTER:
						return _left + ( _width / 2 );
				}
			}
			return _left;
		}

		internal function get numberOfSpaces(): int
		{
			var string: String = toString();
			var length: int = string.length;
			var nSpaces: int = 0;
			var re: Array = string.match( / /g );

			if ( re )
				nSpaces = re.length;

			return nSpaces;
		}

		/**
		 * Gets the number of separators in the line
		 */
		internal function get separatorCount(): int
		{
			var s: int = 0;
			var ck: PdfChunk;

			for ( var i: Iterator = new VectorIterator( Vector.<Object>( line ) ); i.hasNext();  )
			{
				ck = i.next();

				if ( ck.isTab() )
					return 0;

				if ( ck.isHorizontalSeparator() )
				{
					s++;
				}
			}
			return s;
		}

		private function addToLine( chunk: PdfChunk ): void
		{
			if ( chunk.changeLeading && chunk.isImage() )
			{
				var f: Number = chunk.image.scaledHeight + chunk.imageOffsetY + chunk.image.borderWidthTop;

				if ( f > _height )
					_height = f;
			}
			line.push( chunk );
		}
	}
}