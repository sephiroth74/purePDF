/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: MultiColumnText.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/MultiColumnText.as $
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
	import org.purepdf.errors.DocumentError;
	import org.purepdf.pdf.ColumnText;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.utils.pdf_core;

	/**
	 * Formats content into one or more columns bounded by a
	 * rectangle.
	 */
	public class MultiColumnText implements IElement
	{
		use namespace pdf_core;
		
		public static const AUTOMATIC: int = -1;
		internal var _desiredHeight: Number = 0;
		private var totalHeight: Number = 0;
		private var _overflow: Boolean;
		internal var top: Number = AUTOMATIC;
		private var columnText: ColumnText;
		private var columnDefs: Vector.<ColumnDef>;
		private var simple: Boolean = true;
		private var _currentColumn: int = 0;
		private var nextY: Number = AUTOMATIC;
		private var _columnsRightToLeft: Boolean = false;
		private var document: PdfDocument;
		
		public function MultiColumnText()
		{
			columnDefs = new Vector.<ColumnDef>();
			columnText = new ColumnText(null);
			_desiredHeight = AUTOMATIC;
			top = AUTOMATIC;
			totalHeight = 0;
		}
		
		
		public function set desiredHeight( value: int ): void
		{
			_desiredHeight = value;
		}
		
		/**
		 * Copy the parameters from the specified ColumnText
		 */
		public function useColumnParams( sourceColumn: ColumnText ): void
		{
			columnText.setSimpleVars( sourceColumn );
		}
		
		internal function getColumnBottom(): Number
		{
			if( _desiredHeight == AUTOMATIC )
				return document.bottom();
			else
				return Math.max( top - ( _desiredHeight - totalHeight ), document.bottom() );
		}
		
		/**
		 * Adds a new column
		 */
		public function addColumn( left: Vector.<Number>, right: Vector.<Number> ): void
		{
			var nextDef: ColumnDef = new ColumnDef( this );
			nextDef.create( left, right );
			
			if( !nextDef.simple )
				simple = false;
			columnDefs.push( nextDef );
		}
		
		/**
		 * Add a simple rectangular column with specified left
		 * and right x position boundaries.
		 *
		 * @param left  left boundary
		 * @param right right boundary
		 */
		public function addSimpleColumn( left: Number, right: Number ): void
		{
			var newCol: ColumnDef = new ColumnDef( this );
			newCol.createSimple( left, right );
			columnDefs.push( newCol );
		}
		
		/**
		 * Add the specified number of evenly spaced rectangular columns.
		 * Columns will be separated by the specified gutterWidth.
		 *
		 * @param left        left boundary of first column
		 * @param right       right boundary of last column
		 * @param gutterWidth width of gutter spacing between columns
		 * @param numColumns  number of columns to add
		 */
		public function addRegularColumns( left: Number, right: Number, gutterWidth: Number, numColumns: int ): void
		{
			var currX: Number = left;
			var width: Number = right - left;
			var colWidth: Number = (width - (gutterWidth * (numColumns - 1))) / numColumns;
			
			for( var i: int = 0; i < numColumns; i++)
			{
				addSimpleColumn( currX, currX + colWidth );
				currX += colWidth + gutterWidth;
			}
		}
		
		/**
		 * Adds a Phrase to the current text array.
		 * Will not have any effect if addElement() was called before.
		 * @see Phrase
		 */
		public function addPhrase( phrase: Phrase ): void
		{
			columnText.addText( phrase );
		}
		
		/**
		 * Adds a Cunk to the current text array
		 * Will not have any effect if addElement() was called before.
		 * @see Chunk
		 */
		public function addChunk( chunk: Chunk ): void
		{
			columnText.addChunk( chunk );
		}
		
		/**
		 * Add an element to be rendered in a column.
		 * Note that you can only add a Phrase or a Chunk
		 * if the columns are not all simple
		 * 
		 * @param element element to add
		 * @throws DocumentError
		 */
		public function addElement( element: IElement ): void
		{
			if( simple )
				columnText.addElement(element);
			else if( element is Phrase )
				columnText.addText( Phrase(element) );
			else if (element is Chunk )
				columnText.addChunk( Chunk(element) );
			else
				throw new DocumentError("can't add " + element.type + " to multicolumntext");
		}
		
		public function get overflow():Boolean
		{
			return _overflow;
		}

		public function process(listener:IElementListener):Boolean
		{
			try
			{
				listener.addElement( this );
			} catch( e: DocumentError )
			{
			}
			return false;
		}
		
		public function getChunks():Vector.<Object>
		{
			return null;
		}
		
		public function get isNestable():Boolean
		{
			return false;
		}
		
		public function get isContent():Boolean
		{
			return true;
		}
		
		public function toString():String
		{
			return null;
		}
		
		public function get type():int
		{
			return Element.MULTI_COLUMN_TEXT;
		}
		
		/**
		 * Moves the text insertion point to the beginning of the next column.
		 * Adds a page break if needed.
		 * @throws DocumentError
		 */    
		public function nextColumn(): void
		{
			_currentColumn = (_currentColumn + 1) % columnDefs.length;
			top = nextY;
			
			if( _currentColumn == 0 )
				newPage();
		}
		
		public function get currentColumn(): int
		{
			if( _columnsRightToLeft )
				return ( columnDefs.length - _currentColumn - 1 );
			return _currentColumn;
		}
		
		public function resetCurrentColumn(): void
		{
			_currentColumn = 0;
		}
		
		/**
		 * Shifts the current column.
		 * @return true if the current column has changed
		 */
		public function shiftCurrentColumn(): Boolean
		{
			if( _currentColumn + 1 < columnDefs.length )
			{
				_currentColumn++;
				return true;
			}
			return false;
		}
		
		/**
		 * Write out the columns.  After writing, use
		 * overflow to see if all text was written.
		 * @return the current height after writing
		 * @throws DocumentError
		 */
		public function write( canvas: PdfContentByte, document: PdfDocument, documentY: Number ): Number
		{
			this.document = document;
			columnText.canvas = canvas;
			
			if( columnDefs.length == 0 )
				throw new DocumentError( "multicolumntext has no columns" );
			
			_overflow = false;
			var currentHeight: Number = 0;
			var done: Boolean = false;
			
			try 
			{
				while( !done ) 
				{
					if( top == AUTOMATIC )
						top = document.getVerticalPosition( true );
					else if( nextY == AUTOMATIC )
						nextY = document.getVerticalPosition( true );
					
					var currentDef: ColumnDef = columnDefs[ currentColumn ];
					columnText.yLine = top;
					
					var left: Vector.<Number> = currentDef.resolvePositions( RectangleElement.LEFT );
					var right: Vector.<Number> = currentDef.resolvePositions( RectangleElement.RIGHT );
					
					if( document.marginMirroring && document.pageNumber % 2 == 0 )
					{
						var delta: Number = document.marginRight - document.left();
						var i: int;
						left = left.concat();
						right = right.concat();
						
						for( i = 0; i < left.length; i += 2 )
							left[i] -= delta;

						for( i = 0; i < right.length; i += 2 )
							right[i] -= delta;
					}
					
					currentHeight = Math.max( currentHeight, getHeight( left, right ) );
					
					if( currentDef.simple )
						columnText.setSimpleColumn(left[2], left[3], right[0], right[1]);
					else
						columnText.setColumns(left, right);
					
					var result: int = columnText.go();
					if( (result & ColumnText.NO_MORE_TEXT ) != 0 )
					{
						done = true;
						top = columnText.yLine;
					} else if (shiftCurrentColumn()) 
					{
						top = nextY;
					} else 
					{
						totalHeight += currentHeight;
						if( ( _desiredHeight != AUTOMATIC) && ( totalHeight >= _desiredHeight ) )
						{
							_overflow = true;
							break;
						} else
						{
							documentY = nextY;
							newPage();
							currentHeight = 0;
						}
					}
				}
			} catch( ex: DocumentError )
			{
				trace( ex.getStackTrace() );
				throw ex;
			}
			
			if( _desiredHeight == AUTOMATIC && columnDefs.length == 1 )
			{
				currentHeight = documentY - columnText.yLine;
			}
			
			return currentHeight;
		}
		
		/**
		 * Sets the direction of the columns.
		 * @param direction true = right2left; false = left2right
		 */
		public function set columnsRightToLeft( direction: Boolean ): void
		{
			_columnsRightToLeft = direction;
		}
		
		/** 
		 * Sets the ratio between the extra word spacing and the extra character spacing
		 * when the text is fully justified.
		 * If the ratio is PdfWriter.NO_SPACE_CHAR_RATIO then the extra character spacing
		 * will be zero.
		 * 
		 * @see org.purepdf.pdf.PdfWriter#NO_SPACE_CHAR_RATIO
		 */
		public function set spaceCharRatio( spaceCharRatio: Number ): void
		{
			columnText.spaceCharRatio = spaceCharRatio;
		}
		
		/**
		 * 
		 * @see org.purepdf.pdf.PdfWriter#RUN_DIRECTION_DEFAULT
		 * @see org.purepdf.pdf.PdfWriter#RUN_DIRECTION_RTL
		 * @see org.purepdf.pdf.PdfWriter#RUN_DIRECTION_LTR
		 * @see org.purepdf.pdf.PdfWriter#RUN_DIRECTION_NO_BIDI
		 */
		public function set runDirection( runDirection: int ): void
		{
			columnText.runDirection = runDirection;
		}
		
		/** 
		 * Sets the arabic shaping options. The option can be AR_NOVOWEL,
		 * AR_COMPOSEDTASHKEEL and AR_LIG.
		 * 
		 * @see org.purepdf.pdf.ArabicLigaturizer#AR_NOTHING
		 * @see org.purepdf.pdf.ArabicLigaturizer#AR_NOVOWEL
		 * @see org.purepdf.pdf.ArabicLigaturizer#AR_COMPOSEDTASHKEEL
		 * @see org.purepdf.pdf.ArabicLigaturizer#AR_LIG
		 */
		public function set arabicOptions( value: int ): void
		{
			columnText.arabicOptions = value;
		}
		
		/**
		 * 
		 * @see Element#ALIGN_RIGHT
		 * @see Element#ALIGN_CENTER
		 * @see Element#ALIGN_JUSTIFIED
		 * @see Element#ALIGN_LEFT
		 */
		public function set alignment( value: int ): void
		{
			columnText.alignment = value;
		}
		
		/**
		 * Figure out the height of a column from the border extents
		 *
		 * @param left  left border
		 * @param right right border
		 * @return height
		 */
		private function getHeight( left: Vector.<Number>, right: Vector.<Number> ): Number
		{
			var max: Number = Number.MIN_VALUE;
			var min: Number = Number.MAX_VALUE;
			var i: int;
			
			for( i = 0; i < left.length; i += 2 )
			{
				min = Math.min(min, left[i + 1]);
				max = Math.max(max, left[i + 1]);
			}
			
			for( i = 0; i < right.length; i += 2 ) 
			{
				min = Math.min(min, right[i + 1]);
				max = Math.max(max, right[i + 1]);
			}
			return max - min;
		}
		
		/**
		 * 
		 * @throws DocumentError
		 */
		private function newPage(): void
		{
			resetCurrentColumn();
			
			if( _desiredHeight == AUTOMATIC )
				top = nextY = AUTOMATIC;
			else
				top = nextY;
			totalHeight = 0;
			
			if( document != null )
				document.newPage();
		}
	}
}