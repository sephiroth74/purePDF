/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: VerticalText.as 326 2010-02-10 18:17:52Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 326 $ $LastChangedDate: 2010-02-10 13:17:52 -0500 (Wed, 10 Feb 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/VerticalText.as $
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
	import flash.geom.Point;
	
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Phrase;
	import org.purepdf.errors.NullPointerError;
	import org.purepdf.utils.pdf_core;

	public class VerticalText
	{
		use namespace pdf_core;

		public static const NO_MORE_COLUMN: int = 2;
		public static const NO_MORE_TEXT: int = 1;

		protected var _leading: Number = 0;

		protected var _alignment: int = Element.ALIGN_LEFT;
		protected var chunks: Vector.<PdfChunk> = new Vector.<PdfChunk>();
		protected var currentChunkMarker: int = -1;
		protected var currentStandbyChunk: PdfChunk;
		protected var _height: Number;
		protected var _maxLines: int;
		protected var splittedChunkText: String;
		protected var _origin: Point;
		protected var text: PdfContentByte;

		public function VerticalText( content: PdfContentByte )
		{
			this.text = content;
		}

		public function get alignment():int
		{
			return _alignment;
		}

		public function set alignment(value:int):void
		{
			_alignment = value;
		}

		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			_height = value;
		}

		public function get maxLines():int
		{
			return _maxLines;
		}

		public function set maxLines(value:int):void
		{
			_maxLines = value;
		}

		public function get origin():Point
		{
			return _origin;
		}

		public function set origin(value:Point):void
		{
			_origin = value;
		}

		public function addChunk( chunk: Chunk ): void
		{
			chunks.push( PdfChunk.fromChunk( chunk, null ) );
		}

		public function addPhrase( phrase: Phrase ): void
		{
			var ar: Vector.<Object> = phrase.getChunks();
			for ( var k: int = 0; k < ar.length; ++k )
			{
				chunks.push( PdfChunk.fromChunk( Chunk( ar[k] ), null ) );
			}
		}

		/**
		 * Outputs the lines to the document. The output can be simulated.
		 * @param simulate <CODE>true</CODE> to simulate the writing to the document
		 * @return returns the result of the operation. It can be <CODE>NO_MORE_TEXT</CODE>
		 * and/or <CODE>NO_MORE_COLUMN</CODE>
		 */
		public function go( simulate: Boolean = false ): int
		{
			var dirty: Boolean = false;
			var graphics: PdfContentByte = null;
			if ( text != null )
			{
				graphics = text.duplicate();
			} else if ( !simulate )
				throw new NullPointerError( "verticaltext go with simulate == false and text == null" );
			var status: int = 0;
			var line: PdfLine;
			for ( ; ;  )
			{
				if ( maxLines <= 0 )
				{
					status = NO_MORE_COLUMN;
					if ( chunks.length < 1 )
						status |= NO_MORE_TEXT;
					break;
				}
				if ( chunks.length < 1 )
				{
					status = NO_MORE_TEXT;
					break;
				}
				line = createLine( height );
				if ( !simulate && !dirty )
				{
					text.beginText();
					dirty = true;
				}
				shortenChunkArray();
				if ( !simulate )
				{
					text.setTextMatrix( 1, 0, 0, 1, _origin.x, _origin.y - line.pdf_core::indentLeft );
					writeLine( line, text, graphics );
				}
				--maxLines;
				_origin.x -= leading;
			}
			if ( dirty )
			{
				text.endText();
				text.add( graphics );
			}
			return status;
		}

		public function get leading(): Number
		{
			return _leading;
		}

		/**
		 * Sets the separation between the vertical lines.
		 * @param leading the vertical line separation
		 */
		public function set leading( value: Number ): void
		{
			_leading = value;
		}

		/**
		 * Sets the layout.
		 * @param startX the top right X line position
		 * @param startY the top right Y line position
		 * @param height the height of the lines
		 * @param maxLines the maximum number of lines
		 * @param leading the separation between the lines
		 */
		public function setVerticalLayout( startX: Number, startY: Number, height: Number, maxLines: int, leading: Number ): void
		{
			this.origin = new Point( startX, startY );
			this.height = height;
			this.maxLines = maxLines;
			this.leading = leading;
		}

		/**
		 * Creates a line from the chunk array.
		 * @param width the width of the line
		 * @return the line or null if no more chunks
		 */
		protected function createLine( width: Number ): PdfLine
		{
			if ( chunks.length == 0 )
				return null;

			splittedChunkText = null;
			currentStandbyChunk = null;
			var line: PdfLine = new PdfLine( 0, width, alignment, 0 );
			var total: String;
			var original: PdfChunk;
			for ( currentChunkMarker = 0; currentChunkMarker < chunks.length; ++currentChunkMarker )
			{
				original = chunks[currentChunkMarker];
				total = original.toString();
				currentStandbyChunk = line.add( original );
				if ( currentStandbyChunk != null )
				{
					splittedChunkText = original.toString();
					original.setValue( total );
					return line;
				}
			}
			return line;
		}

		/**
		 * Normalizes the list of chunks when the line is accepted.
		 */
		protected function shortenChunkArray(): void
		{
			if ( currentChunkMarker < 0 )
				return;
			if ( currentChunkMarker >= chunks.length )
			{
				chunks.length = 0;
				return;
			}
			var split: PdfChunk = chunks[currentChunkMarker];
			split.setValue( splittedChunkText );
			chunks[currentChunkMarker] = currentStandbyChunk;
			for ( var j: int = currentChunkMarker - 1; j >= 0; --j )
				chunks.splice( j, 1 );
		}

		pdf_core function writeLine( line: PdfLine, text: PdfContentByte, graphics: PdfContentByte ): void
		{
			var currentFont: PdfFont = null;
			var chunk: PdfChunk;
			var color: RGBColor;
			for ( var j: Iterator = line.iterator(); j.hasNext();  )
			{
				chunk = PdfChunk( j.next() );

				if ( chunk.font.compareTo( currentFont ) != 0 )
				{
					currentFont = chunk.font;
					text.setFontAndSize( currentFont.font, currentFont.size );
				}
				color = chunk.color;
				if ( color != null )
					text.setColorFill( color );
				text.showText( chunk.toString() );
				if ( color != null )
					text.resetFill();
			}
		}
	}
}