/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfPRow.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfPRow.as $
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
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.pdf.interfaces.IPdfPCellEvent;

	public class PdfPRow
	{
		public static const BOTTOM_LIMIT: Number = -( 1 << 30 );
		public static const RIGHT_LIMIT: Number = 20000;
		protected var _calculated: Boolean = false;
		protected var _cells: Vector.<PdfPCell>;
		protected var extraHeights: Vector.<Number>;
		protected var _maxHeight: Number = 0;
		protected var widths: Vector.<Number>;
		private var canvasesPos: Vector.<int>;
		
		public function PdfPRow()
		{
		}
		
		public function get maxHeights(): Number
		{
			if( _calculated )
				return _maxHeight;
			return calculateHeights();
		}

		public function set maxHeights(value:Number):void
		{
			_maxHeight = value;
		}

		public function get cells(): Vector.<PdfPCell>
		{
			return _cells;
		}
		
		public function get calculated():Boolean
		{
			return _calculated;
		}

		public function initExtraHeights(): void
		{
			extraHeights = new Vector.<Number>( _cells.length, true );
			for( var i: int = 0; i < extraHeights.length; i++) {
				extraHeights[i] = 0;
			}
		}
		
		/**
		 * Sets an extra height for a cell.
		 */
		public function setExtraHeight( cell: int, height: Number ): void
		{
			if (cell < 0 || cell >= _cells.length)
				return;
			extraHeights[cell] = height;
		}
		
		public function calculateHeights(): Number
		{
			_maxHeight = 0;
			for ( var k: int = 0; k < _cells.length; ++k )
			{
				var cell: PdfPCell = _cells[k];
				var height: Number = 0;
				if (cell == null) {
					continue;
				}
				else {
					height = cell.maxHeight;
					if ((height > _maxHeight) && (cell.rowspan == 1))
						_maxHeight = height;
				}
			}
			_calculated = true;
			return _maxHeight;
		}
		
		/**
		 * Writes the border and background of one cell in the row.
		 */
		public function writeBorderAndBackground( xPos: Number, yPos: Number, currentMaxHeight: Number, cell: PdfPCell, canvases: Vector.<PdfContentByte> ): void
		{
			var background: RGBColor = cell.backgroundColor;
			if (background != null || cell.hasBorders() )
			{
				var right: Number = cell.getRight() + xPos;
				var top: Number = cell.getTop() + yPos;
				var left: Number = cell.getLeft() + xPos;
				var bottom: Number = top - currentMaxHeight;
				
				if (background != null) {
					var backgr: PdfContentByte = canvases[PdfPTable.BACKGROUNDCANVAS];
					backgr.setColorFill(background);
					backgr.rectangle(left, bottom, right - left, top - bottom);
					backgr.fill();
				}
				
				if (cell.hasBorders()) {
					var newRect: RectangleElement = new RectangleElement(left, bottom, right, top);
					newRect.cloneNonPositionParameters(cell);
					newRect.backgroundColor = null;
					var lineCanvas: PdfContentByte = canvases[PdfPTable.LINECANVAS];
					lineCanvas.rectangle(newRect);
				}
			}
		}
		
		protected function saveAndRotateCanvases( canvases: Vector.<PdfContentByte>, a: Number, b: Number, c: Number, d: Number, e: Number, f: Number ): void
		{
			var last: int = PdfPTable.TEXTCANVAS + 1;
			if (canvasesPos == null)
				canvasesPos = new Vector.<int>(last * 2, true);
			for( var k: int = 0; k < last; ++k )
			{
				var bb: ByteBuffer = canvases[k].getInternalBuffer();
				canvasesPos[k * 2] = bb.size;
				canvases[k].saveState();
				canvases[k].concatCTM(a, b, c, d, e, f);
				canvasesPos[k * 2 + 1] = bb.size;
			}
		}
		
		protected function restoreCanvases( canvases: Vector.<PdfContentByte> ): void
		{
			var last: int = PdfPTable.TEXTCANVAS + 1;
			for ( var k: int = 0; k < last; ++k )
			{
				var bb: ByteBuffer = canvases[k].getInternalBuffer();
				var p1: int = bb.size;
				canvases[k].restoreState();
				if (p1 == canvasesPos[k * 2 + 1])
					bb.size = canvasesPos[k * 2];
			}
		}
		
		public function writeCells( colStart: int, colEnd: int, xPos: Number, yPos: Number, canvases: Vector.<PdfContentByte> ): void
		{
			if (!_calculated)
				calculateHeights();
			if (colEnd < 0)
				colEnd = _cells.length;
			else
				colEnd = Math.min(colEnd, _cells.length);
			if (colStart < 0)
				colStart = 0;
			if (colStart >= colEnd)
				return;
			
			var newStart: int;
			var k: int;
			var cell: PdfPCell;
			var ct: ColumnText;
			
			for (newStart = colStart; newStart >= 0; --newStart) {
				if ( _cells[newStart] != null)
					break;
				if (newStart > 0)
					xPos -= widths[newStart - 1];
			}
			
			if (newStart < 0)
				newStart = 0;
			if (cells[newStart] != null)
				xPos -= _cells[newStart].getLeft();
			
			for ( k = newStart; k < colEnd; ++k) {
				cell = cells[k];
				if (cell == null)
					continue;
				var currentMaxHeight: Number = _maxHeight + extraHeights[k];
				writeBorderAndBackground(xPos, yPos, currentMaxHeight, cell, canvases);
				
				var img: ImageElement = cell.image;
				var tly: Number = cell.getTop() + yPos - cell.effectivePaddingTop;
				
				if ( cell.height <= currentMaxHeight )
				{
					switch( cell.verticalAlignment )
					{
						case Element.ALIGN_BOTTOM:
							tly = cell.getTop() + yPos - currentMaxHeight + cell.height - cell.effectivePaddingTop;
							break;
						case Element.ALIGN_MIDDLE:
							tly = cell.getTop() + yPos + (cell.height - currentMaxHeight) / 2 - cell.effectivePaddingTop;
							break;
						default:
							break;
					}
				}
				if (img != null) {
					if (cell.rotation != 0) 
					{
						img.setRotation( img.imageRotation + (cell.rotation * Math.PI / 180.0));
					}
					var vf: Boolean = false;
					if (cell.height > currentMaxHeight) {
						img.scalePercent(100, 100);
						var scale: Number = (currentMaxHeight - cell.effectivePaddingTop - cell.effectivePaddingBottom) / img.scaledHeight;
						img.scalePercent(scale * 100, scale * 100 );
						vf = true;
					}
					var left: Number = cell.getLeft() + xPos + cell.effectivePaddingLeft;
					if (vf) {
						switch (cell.horizontalAlignment) {
							case Element.ALIGN_CENTER:
								left = xPos + (cell.getLeft() + cell.effectivePaddingLeft + cell.getRight() - cell.effectivePaddingRight - img.scaledWidth) / 2;
								break;
							case Element.ALIGN_RIGHT:
								left = xPos + cell.getRight() - cell.effectivePaddingRight - img.scaledWidth;
								break;
							default:
								break;
						}
						tly = cell.getTop() + yPos - cell.effectivePaddingTop;
					}
					
					img.setAbsolutePosition(left, tly - img.scaledHeight);
					
					try 
					{
						canvases[PdfPTable.TEXTCANVAS].addImage(img);
					} catch ( e: DocumentError) {
						throw new ConversionError(e);
					}
				} else {
					// rotation sponsored by Connection GmbH
					if (cell.rotation == 90 || cell.rotation == 270) {
						var netWidth: Number = currentMaxHeight - cell.effectivePaddingTop - cell.effectivePaddingBottom;
						var netHeight: Number = cell.width - cell.effectivePaddingLeft - cell.effectivePaddingRight;
						ct = ColumnText.duplicate(cell.column);
						ct.canvases = canvases;
						ct.setSimpleColumn(0, 0, netWidth + 0.001, -netHeight);
						try {
							ct.go(true);
						} catch ( e: DocumentError ) {
							throw new ConversionError(e);
						}
						var calcHeight: Number = -ct.yLine;
						if (netWidth <= 0 || netHeight <= 0)
							calcHeight = 0;
						if (calcHeight > 0) {
							if (cell.useDescender)
								calcHeight -= ct.descender;
							ct = ColumnText.duplicate(cell.column);
							ct.canvases = canvases;
							ct.setSimpleColumn(-0.003, -0.001, netWidth + 0.003, calcHeight);
							var pivotX: Number;
							var pivotY: Number;
							if (cell.rotation == 90) {
								pivotY = cell.getTop() + yPos - currentMaxHeight + cell.effectivePaddingBottom;
								switch (cell.verticalAlignment) {
									case Element.ALIGN_BOTTOM:
										pivotX = cell.getLeft() + xPos + cell.width - cell.effectivePaddingRight;
										break;
									case Element.ALIGN_MIDDLE:
										pivotX = cell.getLeft() + xPos + (cell.width + cell.effectivePaddingLeft - cell.effectivePaddingRight + calcHeight) / 2;
										break;
									default: //top
										pivotX = cell.getLeft() + xPos + cell.effectivePaddingLeft + calcHeight;
										break;
								}
								saveAndRotateCanvases(canvases, 0,1,-1,0,pivotX,pivotY);
							}
							else {
								pivotY = cell.getTop() + yPos - cell.effectivePaddingTop;
								switch (cell.verticalAlignment) {
									case Element.ALIGN_BOTTOM:
										pivotX = cell.getLeft() + xPos + cell.effectivePaddingLeft;
										break;
									case Element.ALIGN_MIDDLE:
										pivotX = cell.getLeft() + xPos + (cell.width + cell.effectivePaddingLeft - cell.effectivePaddingRight - calcHeight) / 2;
										break;
									default: //top
										pivotX = cell.getLeft() + xPos + cell.width - cell.effectivePaddingRight - calcHeight;
										break;
								}
								saveAndRotateCanvases(canvases, 0,-1,1,0,pivotX,pivotY);
							}
							try {
								ct.go();
							} catch ( e: DocumentError) {
								throw new ConversionError(e);
							} finally {
								restoreCanvases(canvases);
							}
						}
					} 
					else {
						var fixedHeight: Number = cell.fixedHeight;
						var rightLimit: Number = cell.getRight() + xPos - cell.effectivePaddingRight;
						var leftLimit: Number = cell.getLeft() + xPos + cell.effectivePaddingLeft;
						if (cell.noWrap ) {
							switch (cell.horizontalAlignment) {
								case Element.ALIGN_CENTER:
									rightLimit += 10000;
									leftLimit -= 10000;
									break;
								case Element.ALIGN_RIGHT:
									if (cell.rotation == 180) {
										rightLimit += RIGHT_LIMIT;
									}
									else {
										leftLimit -= RIGHT_LIMIT;
									}
									break;
								default:
									if (cell.rotation == 180) {
										leftLimit -= RIGHT_LIMIT;
									}
									else {
										rightLimit += RIGHT_LIMIT;
									}
									break;
							}
						}
						ct = ColumnText.duplicate(cell.column);
						ct.canvases = canvases;
						var bry: Number = tly - (currentMaxHeight - cell.effectivePaddingTop - cell.effectivePaddingBottom);
						if (fixedHeight > 0) {
							if (cell.height > currentMaxHeight) {
								tly = cell.getTop() + yPos - cell.effectivePaddingTop;
								bry = cell.getTop() + yPos - currentMaxHeight + cell.effectivePaddingBottom;
							}
						}
						if( ( tly > bry || ct.hasZeroHeightElement ) && leftLimit < rightLimit) {
							ct.setSimpleColumn(leftLimit, bry - 0.001,	rightLimit, tly);
							if (cell.rotation == 180) {
								var shx: Number = leftLimit + rightLimit;
								var shy: Number = yPos + yPos - currentMaxHeight + cell.effectivePaddingBottom - cell.effectivePaddingTop;
								saveAndRotateCanvases(canvases, -1,0,0,-1,shx,shy);
							}
							try {
								ct.go();
							} catch ( e: DocumentError ) {
								throw new ConversionError(e);
							} finally 
							{
								if (cell.rotation == 180) {
									restoreCanvases(canvases);
								}
							}
						}
					}
				}
				
				var evt: IPdfPCellEvent = cell.cellEvent;
				if (evt != null) 
				{
					var rect: RectangleElement = new RectangleElement(cell.getLeft() + xPos, cell.getTop() + yPos - currentMaxHeight, cell.getRight() + xPos, cell.getTop()	+ yPos);
					evt.cellLayout(cell, rect, canvases);
				}
			}
		}
		
		internal function getEventWidth( xPos: Number ): Vector.<Number> {
			var n: int = 0;
			var k: int;
			for (k = 0; k < _cells.length; ++k) {
				if (_cells[k] != null)
					++n;
			}
			var width: Vector.<Number> = new Vector.<Number>(n + 1, true);
			n = 0;
			width[n++] = xPos;
			for ( k = 0; k < _cells.length; ++k) {
				if (_cells[k] != null) {
					width[n] = width[n - 1] + _cells[k].width;
					++n;
				}
			}
			return width;
		}
		
		
		/**
		 * Sets the widths of the columns in the row.
		 */
		public function setWidths( widths: Vector.<Number> ): Boolean
		{
			if (widths.length != _cells.length)
				return false;
			
			this.widths = widths.concat();
			this.widths.fixed = true;
			var total: Number = 0;
			_calculated = false;
			for( var k: int = 0; k < widths.length; ++k )
			{
				var cell: PdfPCell = _cells[k];
				
				if (cell == null) {
					total += widths[k];
					continue;
				}
				
				cell.setLeft(total);
				var last: int = k + cell.colspan;
				for (; k < last; ++k)
					total += widths[k];
				--k;
				cell.setRight(total);
				cell.setTop(0);
			}
			return true;
		}
		
		
		/**
		 * Splits a row to newHeight.
		 * The returned row is the remainder. It will return null if the newHeight
		 * was so small that only an empty row would result.
		 * 
		 * @param new_height	the new height
		 * @return the remainder row or null if the newHeight was so small that only
		 * an empty row would result
		 */
		public function splitRow( table: PdfPTable, rowIndex: int, new_height: Number ): PdfPRow
		{
			var newCells: Vector.<PdfPCell> = new Vector.<PdfPCell>(cells.length, true);
			var fixHs: Vector.<Number> = new Vector.<Number>(cells.length, true);
			var minHs: Vector.<Number> = new Vector.<Number>(cells.length,true);
			var allEmpty: Boolean = true;
			var k: int;
			var cell: PdfPCell;
			for ( k = 0; k < cells.length; ++k )
			{
				var newHeight: Number = new_height;
				cell = cells[k];
				if (cell == null) {
					var index: int = rowIndex;
					if (table.rowSpanAbove(index, k)) {
						newHeight += table.getRowHeight(index);
						while (table.rowSpanAbove(--index, k)) {
							newHeight += table.getRowHeight(index);
						}
						var row: PdfPRow = table.getRow(index);
						if (row != null && row.cells[k] != null) {
							newCells[k] = PdfPCell.fromCell(row.cells[k]);
							newCells[k].consumeHeight(newHeight);
							newCells[k].rowspan = (row.cells[k].rowspan - rowIndex + index);
							allEmpty = false;
						}
					}
					continue;
				}
				fixHs[k] = cell.fixedHeight;
				minHs[k] = cell.minimumHeight;
				var img: ImageElement = cell.image;
				var newCell: PdfPCell = PdfPCell.fromCell(cell);
				if (img != null) {
					if (newHeight > cell.effectivePaddingBottom + cell.effectivePaddingTop + 2) {
						newCell.phrase = null;
						allEmpty = false;
					}
				}
				else {
					var y: Number;
					var ct: ColumnText = ColumnText.duplicate( cell.column );
					var left: Number = cell.getLeft() + cell.effectivePaddingLeft;
					var bottom: Number = cell.getTop() + cell.effectivePaddingBottom - newHeight;
					var right: Number = cell.getRight() - cell.effectivePaddingRight;
					var top: Number = cell.getTop() - cell.effectivePaddingTop;
					switch( cell.rotation ) {
						case 90:
						case 270:
							y = setColumn(ct, bottom, left, top, right);
							break;
						default:
							y = setColumn(ct, left, bottom, cell.noWrap ? RIGHT_LIMIT : right, top);
							break;
					}
					var status: int;
					try {
						status = ct.go(true);
					}
					catch ( e: DocumentError ) {
						throw new ConversionError(e);
					}
					
					var thisEmpty: Boolean = (ct.yLine == y);
					if (thisEmpty) {
						newCell.column = ColumnText.duplicate( cell.column );
						ct.filledWidth = 0;
					}
					else if ((status & ColumnText.NO_MORE_TEXT) == 0) {
						newCell.column = ct;
						ct.filledWidth = 0;
					}
					else
						newCell.phrase = null;
					allEmpty = (allEmpty && thisEmpty);
				}
				newCells[k] = newCell;
				cell.fixedHeight = newHeight;
			}
			if (allEmpty) {
				for ( k = 0; k < cells.length; ++k) {
					cell = cells[k];
					if (cell == null)
						continue;
					if (fixHs[k] > 0)
						cell.fixedHeight = fixHs[k];
					else
						cell.minimumHeight = minHs[k];
				}
				return null;
			}
			
			calculateHeights();
			var split: PdfPRow = PdfPRow.fromCells(newCells);
			split.widths = widths.concat();
			split.calculateHeights();
			return split;
		}
		

		static public function fromCells( cells: Vector.<PdfPCell> ): PdfPRow
		{
			var r: PdfPRow = new PdfPRow();
			r._cells = cells;
			r.widths = new Vector.<Number>(cells.length, true);
			r.initExtraHeights();
			
			return r;
		}

		static public function fromRow( row: PdfPRow ): PdfPRow
		{
			var r: PdfPRow = new PdfPRow();
			r._maxHeight = row._maxHeight;
			r._calculated = row._calculated;
			r._cells = new Vector.<PdfPCell>(row._cells.length, true);
			for ( var k: int = 0; k < r._cells.length; ++k) {
				if (row._cells[k] != null)
					r._cells[k] = PdfPCell.fromCell( row._cells[k] );
			}
			r.widths = row.widths.concat();
			r.widths.fixed = true;
			r.initExtraHeights();
			return r;
		}

		static public function setColumn( ct: ColumnText, left: Number, bottom: Number, right: Number, top: Number ): Number
		{
			if ( left > right )
				right = left;

			if ( bottom > top )
				top = bottom;
			ct.setSimpleColumn( left, bottom, right, top );
			return top;
		}
	}
}