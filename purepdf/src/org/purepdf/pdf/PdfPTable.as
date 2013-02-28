/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfPTable.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfPTable.as $
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
	import org.purepdf.elements.Element;
	import org.purepdf.elements.IElementListener;
	import org.purepdf.elements.ILargeElement;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NullPointerError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.pdf.events.PdfPTableEventForwarder;
	import org.purepdf.pdf.interfaces.IPdfPTableEvent;
	import org.purepdf.utils.pdf_core;

	/**
	 * This is a table that can be put at an absolute position but can also
	 * be added to the document as the class Table.
	 */
	public class PdfPTable implements ILargeElement
	{
		public static const BACKGROUNDCANVAS: int = 1;
		public static const BASECANVAS: int = 0;
		public static const LINECANVAS: int = 2;
		public static const TEXTCANVAS: int = 3;
		protected var _absoluteWidths: Vector.<Number>;
		protected var _complete: Boolean = true;
		protected var _defaultCell: PdfPCell = PdfPCell.fromPhrase( null );
		protected var _headerRows: int = 0;
		protected var _rows: Vector.<PdfPRow> = new Vector.<PdfPRow>();
		protected var _runDirection: int = PdfWriter.RUN_DIRECTION_DEFAULT;
		protected var _spacingAfter: Number = 0;
		protected var _spacingBefore: Number = 0;
		protected var _totalHeight: Number = 0;
		protected var _totalWidth: Number = 0;
		protected var _widthPercentage: Number = 80;
		protected var currentRow: Vector.<PdfPCell>;
		protected var currentRowIdx: int = 0;
		protected var isColspan: Boolean = false;
		protected var relativeWidths: Vector.<Number>;
		protected var rowCompleted: Boolean = true;
		private var _footerRows: int = 0;
		private var _headersInEvent: Boolean;
		private var _horizontalAlignment: int = Element.ALIGN_CENTER;
		private var _keepTogether: Boolean;
		private var _lockedWidth: Boolean = false;
		private var _skipFirstHeader: Boolean = false;
		private var _skipLastFooter: Boolean = false;
		private var _splitLate: Boolean = true;
		private var _splitRows: Boolean = true;
		private var _tableEvent: IPdfPTableEvent;
		private var _extendLastRow: Vector.<Boolean> = Vector.<Boolean>( [false, false] );

		/**
		 * Create a PdfPTable
		 * init constructor must be one of the following: Number, PdfPTable, Vector.&lt;Number&gt;
		 * 
		 */
		public function PdfPTable( obj: Object = null )
		{
			if ( obj != null )
			{
				if ( obj is Number )
					initFromInt( int( obj ) );
				else if ( obj is PdfPTable )
					initFromTable( PdfPTable( obj ) );
				else if( obj is Vector.<Number> )
					initFromVectorNumber( obj as Vector.<Number> );
				else
					throw new TypeError( "possible elements are: PdfpTable, int" );
			}
		}

		public function set RunDirection( value: int ): void
		{
			switch ( value )
			{
				case PdfWriter.RUN_DIRECTION_DEFAULT:
				case PdfWriter.RUN_DIRECTION_NO_BIDI:
				case PdfWriter.RUN_DIRECTION_LTR:
				case PdfWriter.RUN_DIRECTION_RTL:
					_runDirection = value;
					break;
				default:
					throw new RuntimeError( "invalid run direction" );
			}
		}

		public function get absoluteWidths(): Vector.<Number>
		{
			return _absoluteWidths;
		}

		public function addCell( cell: PdfPCell ): void
		{
			rowCompleted = false;
			var ncell: PdfPCell = PdfPCell.fromCell( cell );
			var colspan: int = ncell.colspan;
			colspan = Math.max( colspan, 1 );
			colspan = Math.min( colspan, currentRow.length - currentRowIdx );
			ncell.colspan = colspan;

			if ( colspan != 1 )
				isColspan = true;
			var rdir: int = ncell.runDirection;

			if ( rdir == PdfWriter.RUN_DIRECTION_DEFAULT )
				ncell.runDirection = runDirection;
			skipColsWithRowspanAbove();
			var cellAdded: Boolean = false;

			if ( currentRowIdx < currentRow.length )
			{
				currentRow[currentRowIdx] = ncell;
				currentRowIdx += colspan;
				cellAdded = true;
			}
			skipColsWithRowspanAbove();

			if ( currentRowIdx >= currentRow.length )
			{
				var numCols: int = columnsCount;

				if ( runDirection == PdfWriter.RUN_DIRECTION_RTL )
				{
					var rtlRow: Vector.<PdfPCell> = new Vector.<PdfPCell>( numCols, true );
					var rev: int = currentRow.length;

					for ( var k: int = 0; k < currentRow.length; ++k )
					{
						var rcell: PdfPCell = currentRow[k];
						var cspan: int = rcell.colspan;
						rev -= cspan;
						rtlRow[rev] = rcell;
						k += cspan - 1;
					}
					currentRow = rtlRow;
				}
				var row: PdfPRow = PdfPRow.fromCells( currentRow );

				if ( _totalWidth > 0 )
				{
					row.setWidths( _absoluteWidths );
					_totalHeight += row.maxHeights;
				}
				_rows.push( row );
				currentRow = new Vector.<PdfPCell>( numCols, true );
				currentRowIdx = 0;
				rowCompleted = true;
			}

			if ( !cellAdded )
			{
				currentRow[currentRowIdx] = ncell;
				currentRowIdx += colspan;
			}
		}

		public function addImageCell( image: ImageElement ): void
		{
			_defaultCell.image = image;
			addCell( _defaultCell );
			_defaultCell.image = null;
		}

		public function addPhraseCell( phrase: Phrase ): void
		{
			_defaultCell.phrase = phrase;
			addCell( _defaultCell );
			_defaultCell.phrase = null;
		}

		public function addStringCell( text: String ): void
		{
			addPhraseCell( new Phrase( text, null ) );
		}

		public function addTableCell( table: PdfPTable ): void
		{
			_defaultCell.table = table;
			addCell( _defaultCell );
			_defaultCell.table = null;
		}

		public function calculateHeights( firsttime: Boolean ): Number
		{
			if ( _totalWidth <= 0 )
				return 0;
			_totalHeight = 0;

			for ( var k: int = 0; k < _rows.length; ++k )
			{
				_totalHeight += getRowHeight1( k, firsttime );
			}
			return _totalHeight;
		}

		public function calculateHeightsFast(): void
		{
			calculateHeights( false );
		}

		public function get columnsCount(): int
		{
			return relativeWidths.length;
		}

		public function get complete(): Boolean
		{
			return _complete;
		}

		public function set complete( value: Boolean ): void
		{
			_complete = value;
		}

		public function completeRow(): void
		{
			while ( !rowCompleted )
			{
				addCell( _defaultCell );
			}
		}

		public function get defaultCell(): PdfPCell
		{
			return _defaultCell;
		}

		public function deleteBodyRows(): void
		{
			var rows2: Vector.<PdfPRow> = new Vector.<PdfPRow>();

			for ( var k: int = 0; k < headerRows; ++k )
				rows2.push( _rows[k] );
			_rows = rows2;
			_totalHeight = 0;

			if ( _totalWidth > 0 )
				_totalHeight = headerHeight;
		}

		public function deleteLastRow(): Boolean
		{
			return deleteRow( _rows.length - 1 );
		}

		public function deleteRow( rowNumber: int ): Boolean
		{
			if ( rowNumber < 0 || rowNumber >= _rows.length )
				return false;

			if ( _totalWidth > 0 )
			{
				var row: PdfPRow = _rows[rowNumber];

				if ( row != null )
					_totalHeight -= row.maxHeights;
			}
			_rows.splice( rowNumber, 1 );

			if ( rowNumber < headerRows )
			{
				--headerRows;

				if ( rowNumber >= ( headerRows - _footerRows ) )
					--_footerRows;
			}
			return true;
		}

		public function flushContent(): void
		{
			deleteBodyRows();
			skipFirstHeader = true;
		}

		public function get footerHeight(): Number
		{
			var total: Number = 0;
			var start: int = Math.max( 0, headerRows - _footerRows );
			var s: int = Math.min( _rows.length, headerRows );

			for ( var k: int = start; k < s; ++k )
			{
				var row: PdfPRow = _rows[k];

				if ( row != null )
					total += row.maxHeights;
			}
			return total;
		}

		public function get footerRows(): int
		{
			return _footerRows;
		}

		public function set footerRows( value: int ): void
		{
			_footerRows = Math.max( value, 0 );
		}

		public function getChunks(): Vector.<Object>
		{
			return new Vector.<Object>();
		}

		public function getRow( idx: int ): PdfPRow
		{
			return _rows[idx];
		}

		public function getRowHeight( idx: int ): Number
		{
			return getRowHeight1( idx, false );
		}

		public function getRowHeight1( idx: int, firsttime: Boolean ): Number
		{
			if ( _totalWidth <= 0 || idx < 0 || idx >= _rows.length )
				return 0;
			var row: PdfPRow = _rows[idx];

			if ( row == null )
				return 0;

			if ( firsttime )
				row.setWidths( _absoluteWidths );
			var height: Number = row.maxHeights;
			var cell: PdfPCell;
			var tmprow: PdfPRow;

			for ( var i: int = 0; i < relativeWidths.length; i++ )
			{
				if ( !rowSpanAbove( idx, i ) )
					continue;
				var rs: int = 1;

				while ( rowSpanAbove( idx - rs, i ) )
				{
					rs++;
				}
				tmprow = _rows[( idx - rs )];
				cell = tmprow.cells[i];
				var tmp: Number = 0;

				if ( cell.rowspan == rs + 1 )
				{
					tmp = cell.maxHeight;

					while ( rs > 0 )
					{
						tmp -= getRowHeight( idx - rs );
						rs--;
					}
				}

				if ( tmp > height )
					height = tmp;
			}
			row.maxHeights = height;
			return height;
		}

		public function getRows( start: int, end: int ): Vector.<PdfPRow>
		{
			var list: Vector.<PdfPRow> = new Vector.<PdfPRow>();

			if ( start < 0 || end > size )
			{
				return list;
			}
			var firstRow: PdfPRow = adjustCellsInRow( start, end );
			var colIndex: int = 0;
			var cell: PdfPCell;

			while ( colIndex < columnsCount )
			{
				var rowIndex: int = start;

				while ( rowSpanAbove( rowIndex--, colIndex ) )
				{
					var row: PdfPRow = _rows[rowIndex];

					if ( row != null )
					{
						var replaceCell: PdfPCell = row.cells[colIndex];

						if ( replaceCell != null )
						{
							firstRow.cells[colIndex] = PdfPCell.fromCell( replaceCell );
							var extra: Number = 0;
							var stop: int = Math.min( rowIndex + replaceCell.rowspan, end );

							for ( var j: int = start + 1; j < stop; j++ )
							{
								extra += getRowHeight( j );
							}
							firstRow.setExtraHeight( colIndex, extra );
							var diff: Number = getRowspanHeight( rowIndex, colIndex ) - getRowHeight( start ) - extra;
							firstRow.cells[colIndex].consumeHeight( diff );
						}
					}
				}
				cell = firstRow.cells[colIndex];

				if ( cell == null )
					colIndex++;
				else
					colIndex += cell.colspan;
			}
			list.push( firstRow );

			for ( var i: int = start + 1; i < end; i++ )
			{
				list.push( adjustCellsInRow( i, end ) );
			}
			return list;
		}

		public function getRowspanHeight( rowIndex: int, cellIndex: int ): Number
		{
			if ( _totalWidth <= 0 || rowIndex < 0 || rowIndex >= _rows.length )
				return 0;
			var row: PdfPRow = _rows[rowIndex];

			if ( row == null || cellIndex >= row.cells.length )
				return 0;
			var cell: PdfPCell = row.cells[cellIndex];

			if ( cell == null )
				return 0;
			var rowspanHeight: Number = 0;

			for ( var j: int = 0; j < cell.rowspan; j++ )
			{
				rowspanHeight += getRowHeight( rowIndex + j );
			}
			return rowspanHeight;
		}

		public function get headerHeight(): Number
		{
			var total: Number = 0;
			var s: int = Math.min( _rows.length, headerRows );

			for ( var k: int = 0; k < s; ++k )
			{
				var row: PdfPRow = _rows[k];

				if ( row != null )
					total += row.maxHeights;
			}
			return total;
		}

		public function get headerRows(): int
		{
			return _headerRows;
		}

		public function set headerRows( value: int ): void
		{
			_headerRows = Math.max( value, 0 );
		}

		public function get headersInEvent(): Boolean
		{
			return _headersInEvent;
		}

		public function set headersInEvent( value: Boolean ): void
		{
			_headersInEvent = value;
		}

		public function get horizontalAlignment(): int
		{
			return _horizontalAlignment;
		}

		public function set horizontalAlignment( value: int ): void
		{
			_horizontalAlignment = value;
		}

		public function get isContent(): Boolean
		{
			return true;
		}

		public function get extendLastRow(): Boolean
		{
			return _extendLastRow[0];
		}

		public function isExtendLastRow( newPageFollows: Boolean ): Boolean
		{
			if ( newPageFollows )
			{
				return _extendLastRow[0];
			}
			return _extendLastRow[1];
		}

		public function get isNestable(): Boolean
		{
			return true;
		}

		public function get keepTogether(): Boolean
		{
			return _keepTogether;
		}

		public function set keepTogether( value: Boolean ): void
		{
			_keepTogether = value;
		}

		public function get lockedWidth(): Boolean
		{
			return _lockedWidth;
		}

		public function set lockedWidth( value: Boolean ): void
		{
			_lockedWidth = value;
		}

		public function process( listener: IElementListener ): Boolean
		{
			try
			{
				return listener.addElement( this );
			} catch ( e: DocumentError )
			{
			}
			return false;
		}

		public function get rows(): Vector.<PdfPRow>
		{
			return _rows;
		}

		public function get runDirection(): int
		{
			return _runDirection;
		}

		public function set extendLastRow( value: Boolean ): void
		{
			_extendLastRow[0] = value;
			_extendLastRow[1] = value;
		}

		public function setExtendLastRow( value1: Boolean, value2: Boolean ): void
		{
			_extendLastRow[0] = value1;
			_extendLastRow[1] = value2;
		}

		/**
		 * @throws DocumentError
		 */
		public function setIntWidths( relativeWidths: Vector.<int> ): void
		{
			var tb: Vector.<Number> = new Vector.<Number>( relativeWidths.length, true );

			for ( var k: int = 0; k < relativeWidths.length; ++k )
				tb[k] = relativeWidths[k];
			setNumberWidths( tb );
		}

		/**
		 *
		 * @throws DocumentError
		 */
		public function setNumberWidths( $relativeWidths: Vector.<Number> ): void
		{
			if ( relativeWidths.length != columnsCount )
				throw new DocumentError( "wrong number of columns" );
			relativeWidths = $relativeWidths.concat();
			_absoluteWidths = new Vector.<Number>( relativeWidths.length, true );
			_totalHeight = 0;
			calculateWidths();
			calculateHeights( true );
		}

		/**
		 * @throws DocumentError
		 */
		public function setTotalWidths( value: Vector.<Number> ): void
		{
			if ( value.length != columnsCount )
				throw new DocumentError( "wrong number of columns" );
			_totalWidth = 0;

			for ( var k: int = 0; k < value.length; ++k )
				_totalWidth += value[k];
			setNumberWidths( value );
		}

		/**
		 * @throws DocumentError
		 */
		public function setWidthPercentageAndSize( columnWidth: Vector.<Number>, pageSize: RectangleElement ): void
		{
			if ( columnWidth.length != columnsCount )
				throw new DocumentError( "wrong number of columns" );
			var totalWidth: Number = 0;

			for ( var k: int = 0; k < columnWidth.length; ++k )
				totalWidth += columnWidth[k];
			_widthPercentage = totalWidth / ( pageSize.getRight() - pageSize.getLeft() ) * 100;
			setNumberWidths( columnWidth );
		}

		public function get size(): int
		{
			return _rows.length;
		}

		public function get skipFirstHeader(): Boolean
		{
			return _skipFirstHeader;
		}

		public function set skipFirstHeader( value: Boolean ): void
		{
			_skipFirstHeader = value;
		}

		public function get skipLastFooter(): Boolean
		{
			return _skipLastFooter;
		}

		public function set skipLastFooter( value: Boolean ): void
		{
			_skipLastFooter = value;
		}

		public function get spacingAfter(): Number
		{
			return _spacingAfter;
		}

		public function set spacingAfter( value: Number ): void
		{
			_spacingAfter = value;
		}

		public function get spacingBefore(): Number
		{
			return _spacingBefore;
		}

		public function set spacingBefore( value: Number ): void
		{
			_spacingBefore = value;
		}

		public function get splitLate(): Boolean
		{
			return _splitLate;
		}

		public function set splitLate( value: Boolean ): void
		{
			_splitLate = value;
		}

		public function get splitRows(): Boolean
		{
			return _splitRows;
		}

		public function set splitRows( value: Boolean ): void
		{
			_splitRows = value;
		}

		public function get tableEvent(): IPdfPTableEvent
		{
			return _tableEvent;
		}

		public function set tableEvent( event: IPdfPTableEvent ): void
		{
			if ( event == null )
				_tableEvent = null;
			else if ( _tableEvent == null )
				_tableEvent = event;
			else if ( _tableEvent is PdfPTableEventForwarder )
				PdfPTableEventForwarder( _tableEvent ).addTableEvent( event );
			else
			{
				var forward: PdfPTableEventForwarder = new PdfPTableEventForwarder();
				forward.addTableEvent( _tableEvent );
				forward.addTableEvent( event );
				_tableEvent = forward;
			}
		}

		public function toString(): String
		{
			return "[PdfPTable]";
		}

		public function get totalHeight(): Number
		{
			return _totalHeight;
		}

		public function get totalWidth(): Number
		{
			return _totalWidth;
		}

		public function set totalWidth( value: Number ): void
		{
			if ( _totalWidth == value )
				return;
			_totalWidth = value;
			_totalHeight = 0;
			calculateWidths();
			calculateHeights( true );
		}

		public function get type(): int
		{
			return Element.PTABLE;
		}

		public function get widthPercentage(): Number
		{
			return _widthPercentage;
		}

		public function set widthPercentage( value: Number ): void
		{
			_widthPercentage = value;
		}

		public function writeSelectedRows( rowStart: int, rowEnd: int, xPos: Number, yPos: Number, canvases: Vector.<PdfContentByte> ): Number
		{
			return writeSelectedRows1( 0, -1, rowStart, rowEnd, xPos, yPos, canvases );
		}

		/**
		 * @throws RuntimeError
		 */
		public function writeSelectedRows1( colStart: int, colEnd: int, rowStart: int, rowEnd: int, xPos: Number, yPos: Number,
						canvases: Vector.<PdfContentByte> ): Number
		{
			if ( _totalWidth <= 0 )
				throw new RuntimeError( "the table width must be greater than zero" );
			var totalRows: int = _rows.length;

			if ( rowStart < 0 )
				rowStart = 0;

			if ( rowEnd < 0 )
				rowEnd = totalRows;
			else
				rowEnd = Math.min( rowEnd, totalRows );

			if ( rowStart >= rowEnd )
				return yPos;
			var totalCols: int = columnsCount;

			if ( colStart < 0 )
				colStart = 0;
			else
				colStart = Math.min( colStart, totalCols );

			if ( colEnd < 0 )
				colEnd = totalCols;
			else
				colEnd = Math.min( colEnd, totalCols );
			var yPosStart: Number = yPos;
			var k: int;
			var row: PdfPRow;

			for ( k = rowStart; k < rowEnd; ++k )
			{
				row = _rows[k];

				if ( row != null )
				{
					row.writeCells( colStart, colEnd, xPos, yPos, canvases );
					yPos -= row.maxHeights;
				}
			}

			if ( _tableEvent != null && colStart == 0 && colEnd == totalCols )
			{
				var heights: Vector.<Number> = new Vector.<Number>( rowEnd - rowStart + 1, true );
				heights[0] = yPosStart;

				for ( k = rowStart; k < rowEnd; ++k )
				{
					row = rows[k];
					var hr: Number = 0;

					if ( row != null )
						hr = row.maxHeights;
					heights[k - rowStart + 1] = heights[k - rowStart] - hr;
				}
				tableEvent.tableLayout( this, getEventWidths( xPos, rowStart, rowEnd, headersInEvent ), heights, headersInEvent ? headerRows : 0, rowStart, canvases );
			}
			return yPos;
		}

		public function writeSelectedRows2( rowStart: int, rowEnd: int, xPos: Number, yPos: Number, canvas: PdfContentByte ): Number
		{
			return writeSelectedRows3( 0, -1, rowStart, rowEnd, xPos, yPos, canvas );
		}

		public function writeSelectedRows3( colStart: int, colEnd: int, rowStart: int, rowEnd: int, xPos: Number, yPos: Number,
						canvas: PdfContentByte ): Number
		{
			var totalCols: int = columnsCount;

			if ( colStart < 0 )
				colStart = 0;
			else
				colStart = Math.min( colStart, totalCols );

			if ( colEnd < 0 )
				colEnd = totalCols;
			else
				colEnd = Math.min( colEnd, totalCols );
			var clip: Boolean = ( colStart != 0 || colEnd != totalCols );

			if ( clip )
			{
				var w: Number = 0;

				for ( var k: int = colStart; k < colEnd; ++k )
					w += _absoluteWidths[k];
				canvas.saveState();
				var lx: Number = ( colStart == 0 ) ? 10000 : 0;
				var rx: Number = ( colEnd == totalCols ) ? 10000 : 0;
				canvas.rectangle( xPos - lx, -10000, w + lx + rx, PdfPRow.RIGHT_LIMIT );
				canvas.clip();
				canvas.newPath();
			}
			var canvases: Vector.<PdfContentByte> = beginWritingRows( canvas );
			var y: Number = writeSelectedRows1( colStart, colEnd, rowStart, rowEnd, xPos, yPos, canvases );
			endWritingRows( canvases );

			if ( clip )
				canvas.restoreState();
			return y;
		}

		protected function adjustCellsInRow( start: int, end: int ): PdfPRow
		{
			var row: PdfPRow = PdfPRow.fromRow( _rows[start] );
			row.initExtraHeights();
			var k: int;
			var cell: PdfPCell;
			var cells: Vector.<PdfPCell> = row.cells;

			for ( var i: int = 0; i < cells.length; i++ )
			{
				cell = cells[i];

				if ( cell == null || cell.rowspan == 1 )
					continue;
				var stop: int = Math.min( end, start + cell.rowspan );
				var extra: Number = 0;

				for ( k = start + 1; k < stop; k++ )
				{
					extra += getRowHeight( k );
				}
				row.setExtraHeight( i, extra );
			}
			return row;
		}

		protected function calculateWidths(): void
		{
			if ( _totalWidth <= 0 )
				return;
			var total: Number = 0;
			var k: int;
			var numCols: int = columnsCount;

			for ( k = 0; k < numCols; ++k )
				total += relativeWidths[k];

			for ( k = 0; k < numCols; ++k )
				_absoluteWidths[k] = _totalWidth * relativeWidths[k] / total;
		}

		protected function copyFormat( sourceTable: PdfPTable ): void
		{
			relativeWidths = sourceTable.relativeWidths.concat();
			relativeWidths.length = columnsCount;
			_absoluteWidths = sourceTable._absoluteWidths.concat();
			_absoluteWidths.length = columnsCount;
			_totalWidth = sourceTable._totalWidth;
			_totalHeight = sourceTable._totalHeight;
			currentRowIdx = 0;
			_runDirection = sourceTable.runDirection;
			_tableEvent = sourceTable.tableEvent;
			_defaultCell = PdfPCell.fromCell( sourceTable._defaultCell );
			currentRow = new Vector.<PdfPCell>( sourceTable.currentRow.length, true );
			isColspan = sourceTable.isColspan;
			_splitRows = sourceTable._splitRows;
			_spacingAfter = sourceTable._spacingAfter;
			_spacingBefore = sourceTable._spacingBefore;
			headerRows = sourceTable.headerRows;
			_footerRows = sourceTable._footerRows;
			_lockedWidth = sourceTable._lockedWidth;
			_extendLastRow = sourceTable._extendLastRow;
			_headersInEvent = sourceTable._headersInEvent;
			_widthPercentage = sourceTable._widthPercentage;
			_splitLate = sourceTable._splitLate;
			_skipFirstHeader = sourceTable._skipFirstHeader;
			_skipLastFooter = sourceTable._skipLastFooter;
			_horizontalAlignment = sourceTable._horizontalAlignment;
			_keepTogether = sourceTable._keepTogether;
			_complete = sourceTable._complete;
		}

		private function getEventWidths( xPos: Number, firstRow: int, lastRow: int, includeHeaders: Boolean ): Vector.<Vector.<Number>>
		{
			if ( includeHeaders )
			{
				firstRow = Math.max( firstRow, headerRows );
				lastRow = Math.max( lastRow, headerRows );
			}
			var k: int;
			var row: PdfPRow;
			var widths: Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>( ( includeHeaders ? headerRows : 0 ) + lastRow -
							firstRow, true );

			if ( isColspan )
			{
				var n: int = 0;

				if ( includeHeaders )
				{
					for ( k = 0; k < headerRows; ++k )
					{
						row = _rows[k];

						if ( row == null )
							++n;
						else
							widths[n++] = row.getEventWidth( xPos );
					}
				}

				for ( ; firstRow < lastRow; ++firstRow )
				{
					row = _rows[firstRow];

					if ( row == null )
						++n;
					else
						widths[n++] = row.getEventWidth( xPos );
				}
			} else
			{
				var numCols: int = columnsCount;
				var width: Vector.<Number> = new Vector.<Number>( numCols + 1, true );
				width[0] = xPos;

				for ( k = 0; k < numCols; ++k )
					width[k + 1] = width[k] + _absoluteWidths[k];

				for ( k = 0; k < widths.length; ++k )
					widths[k] = width;
			}
			return widths;
		}
		
		private function initFromVectorNumber( value: Vector.<Number> ): void
		{
			if ( value == null )
				throw new NullPointerError("widths can't be null");
			if (value.length == 0)
				throw new ArgumentError("widths array can't be empty");
			
			relativeWidths = value.concat();
			
			_absoluteWidths = new Vector.<Number>(relativeWidths.length, true);
			calculateWidths();
			currentRow = new Vector.<PdfPCell>(absoluteWidths.length, true);
			_keepTogether = false;
		}

		private function initFromInt( numColumns: int ): void
		{
			if ( numColumns <= 0 )
				throw new ArgumentError( "the number of columns must be greater than zero" );
			relativeWidths = new Vector.<Number>( numColumns, true );

			for ( var k: int = 0; k < numColumns; ++k )
				relativeWidths[k] = 1;
			_absoluteWidths = new Vector.<Number>( relativeWidths.length, true );
			calculateWidths();
			currentRow = new Vector.<PdfPCell>( _absoluteWidths.length, true );
			_keepTogether = false;
		}

		private function initFromTable( o: PdfPTable ): void
		{
			var k: int;
			copyFormat( o );

			for ( k = 0; k < currentRow.length; ++k )
			{
				if ( o.currentRow[k] == null )
					break;
				currentRow[k] = PdfPCell.fromCell( o.currentRow[k] );
			}

			for ( k = 0; k < o._rows.length; ++k )
			{
				var row: PdfPRow = ( o._rows[k] );

				if ( row != null )
					row = PdfPRow.fromRow( row );
				_rows.push( row );
			}
		}

		private function skipColsWithRowspanAbove(): void
		{
			var direction: int = 1;

			if ( runDirection == PdfWriter.RUN_DIRECTION_RTL )
				direction = -1;

			while ( rowSpanAbove( _rows.length, currentRowIdx ) )
				currentRowIdx += direction;
		}

		/**
		 * Checks if there are rows above belonging to a rowspan
		 */
		internal function rowSpanAbove( currRow: int, currCol: int ): Boolean
		{
			if ( ( currCol >= columnsCount ) || ( currCol < 0 ) || ( currRow == 0 ) )
				return false;
			var row: int = currRow - 1;
			var col: int;
			var aboveRow: PdfPRow = _rows[row];

			if ( aboveRow == null )
				return false;
			var aboveCell: PdfPCell = aboveRow.cells[currCol];

			while ( ( aboveCell == null ) && ( row > 0 ) )
			{
				aboveRow = _rows[--row];

				if ( aboveRow == null )
					return false;
				aboveCell = aboveRow.cells[currCol];
			}
			var distance: int = currRow - row;

			if ( aboveCell == null )
			{
				col = currCol - 1;
				aboveCell = aboveRow.cells[col];

				while ( ( aboveCell == null ) && ( row > 0 ) )
					aboveCell = aboveRow.cells[--col];
				return aboveCell != null && aboveCell.rowspan > distance;
			}

			if ( ( aboveCell.rowspan == 1 ) && ( distance > 1 ) )
			{
				col = currCol - 1;
				aboveRow = _rows[( row + 1 )];
				distance--;
				aboveCell = aboveRow.cells[col];

				while ( ( aboveCell == null ) && ( col > 0 ) )
					aboveCell = aboveRow.cells[--col];
			}
			return aboveCell != null && aboveCell.rowspan > distance;
		}

		pdf_core function set rows( value: Vector.<PdfPRow> ): void
		{
			_rows = value;
		}

		static public function beginWritingRows( canvas: PdfContentByte ): Vector.<PdfContentByte>
		{
			return Vector.<PdfContentByte>( [
							canvas, canvas.duplicate(), canvas.duplicate(), canvas.duplicate(),
							] );
		}

		static public function endWritingRows( canvases: Vector.<PdfContentByte> ): void
		{
			var canvas: PdfContentByte = canvases[BASECANVAS];
			canvas.saveState();
			canvas.addContent( canvases[BACKGROUNDCANVAS] );
			canvas.restoreState();
			canvas.saveState();
			canvas.setLineCap( 2 );
			canvas.resetStroke();
			canvas.addContent( canvases[LINECANVAS] );
			canvas.restoreState();
			canvas.addContent( canvases[TEXTCANVAS] );
		}

		static public function shallowCopy( table: PdfPTable ): PdfPTable
		{
			var nt: PdfPTable = new PdfPTable( null );
			nt.copyFormat( table );
			return nt;
		}
	}
}