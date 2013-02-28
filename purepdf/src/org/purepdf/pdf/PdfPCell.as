/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfPCell.as 317 2010-02-10 11:09:52Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 317 $ $LastChangedDate: 2010-02-10 06:09:52 -0500 (Wed, 10 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfPCell.as $
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
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.IElement;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.pdf.events.PdfPCellEventForwarder;
	import org.purepdf.pdf.interfaces.IPdfPCellEvent;

	public class PdfPCell extends RectangleElement
	{
		protected var _phrase: Phrase;
		private var _colspan: int = 1;
		private var _column: ColumnText = new ColumnText( null );
		private var _fixedHeight: Number = 0;
		private var _image: ImageElement;
		private var _minimumHeight: Number;
		private var _noWrap: Boolean = false;
		private var _paddingBottom: Number = 2;
		private var _paddingLeft: Number = 2;
		private var _paddingRight: Number = 2;
		private var _paddingTop: Number = 2;
		private var _rowspan: int = 1;
		private var _table: PdfPTable;
		private var _useBorderPadding: Boolean = false;
		private var _useDescender: Boolean;
		private var _verticalAlignment: int = Element.ALIGN_TOP;
		private var _cellEvent: IPdfPCellEvent;

		public function PdfPCell()
		{
			super( 0, 0, 0, 0 );
			_borderWidth = 0.5;
			_border = BOX;
			_column.setLeading(0, 1);			
		}
		
		public static function fromTable( table: PdfPTable, style: PdfPCell = null ): PdfPCell
		{
			var r: PdfPCell = new PdfPCell();
			r._borderWidth = 0.5;
			r._border = BOX;
			r._column.setLeading(0, 1);
			r._table = table;
			r._table.widthPercentage = 100;
			r._table.extendLastRow = true;
			r._column.addElement(table);
			
			if( style != null )
			{
				r.cloneNonPositionParameters(style);
				r._verticalAlignment = style._verticalAlignment;
				r._paddingLeft = style._paddingLeft;
				r._paddingRight = style._paddingRight;
				r._paddingTop = style._paddingTop;
				r._paddingBottom = style._paddingBottom;
				r._colspan = style._colspan;
				r._rowspan = style._rowspan;
				r._cellEvent = style._cellEvent;
				r._useDescender = style._useDescender;
				r._useBorderPadding = style._useBorderPadding;
				r._rotation = style._rotation;
			}
			else
				r.padding = 0;
			return r;
		}
		
		public function get cellEvent(): IPdfPCellEvent
		{
			return _cellEvent;
		}
		
		public function set cellEvent( value: IPdfPCellEvent ): void
		{
			if( value == null)
				_cellEvent = null;
			else if (_cellEvent == null)
				_cellEvent = value;
			else if (_cellEvent is PdfPCellEventForwarder )
				PdfPCellEventForwarder(_cellEvent).addCellEvent(cellEvent);
			else {
				var forward: PdfPCellEventForwarder = new PdfPCellEventForwarder();
				forward.addCellEvent(_cellEvent);
				forward.addCellEvent( value );
				_cellEvent = forward;
			}
		}
		
		public function get runDirection(): int
		{
			return _column.runDirection;
		}
		
		public function set runDirection( value: int ): void
		{
			_column.runDirection = value;
		}
		
		public function get column():ColumnText
		{
			return _column;
		}
		
		public function set column( value: ColumnText ): void
		{
			_column = value;
		}

		public function get useDescender():Boolean
		{
			return _useDescender;
		}

		public function set useDescender(value:Boolean):void
		{
			_useDescender = value;
		}
		
		public function get useAscender(): Boolean
		{
			return _column.useAscender;
		}
		
		public function set useAscender( value: Boolean ): void
		{
			_column.useAscender = value;
		}

		public function get image():ImageElement
		{
			return _image;
		}

		public function set image(value:ImageElement):void
		{
			_column.setText( null );
			_table = null;
			_image = value;
		}

		public function get rightIndent(): Number
		{
			return _column.rightIndent;
		}
		
		public function set rightIndent( value: Number ): void
		{
			_column.rightIndent = value;
		}
		
		public function get followingIndent():Number
		{
			return _column.followingIndent;
		}
		
		public function set followingIndent(value:Number):void
		{
			_column.followingIndent = value;
		}
		
		
		public function get rowspan():int
		{
			return _rowspan;
		}

		public function set rowspan(value:int):void
		{
			_rowspan = value;
		}

		public function get colspan():int
		{
			return _colspan;
		}

		public function set colspan(value:int):void
		{
			_colspan = value;
		}

		public function get table():PdfPTable
		{
			return _table;
		}

		public function set table(value:PdfPTable):void
		{
			_table = value;
			_column.setText(null);
			_image = null;
			if (_table != null) {
				_table.extendLastRow = (verticalAlignment == Element.ALIGN_TOP);
				_column.addElement(table);
				_table.widthPercentage = 100;
			}
		}
		
		public function set rotation( value: int ): void
		{
			value %= 360;
			if (value < 0)
				value += 360;
			if ((value % 90) != 0)
				throw new ArgumentError("rotation must be a multiple of 90");
			_rotation = value;
		}

		public function get noWrap():Boolean
		{
			return _noWrap;
		}

		public function set noWrap(value:Boolean):void
		{
			_noWrap = value;
		}

		public function get hasMinimumHeight(): Boolean
		{
			return minimumHeight > 0;
		}
		
		public function get minimumHeight():Number
		{
			return _minimumHeight;
		}

		public function set minimumHeight(value:Number):void
		{
			_minimumHeight = value;
			_fixedHeight = 0;
		}

		public function get hasFixedHeight(): Boolean
		{
			return fixedHeight > 0;
		}
		
		public function get fixedHeight():Number
		{
			return _fixedHeight;
		}

		public function set fixedHeight(value:Number):void
		{
			_fixedHeight = value;
			_minimumHeight = 0;
		}

		public function get extraParagraphSpace(): Number
		{
			return _column.extraParagraphSpace;
		}
		
		public function set extraParagraphSpace( value: Number ): void
		{
			_column.extraParagraphSpace = value;
		}
		
		public function set indent( value: Number ): void
		{
			_column.indent = value;
		}
		
		public function get indent(): Number
		{
			return _column.indent;
		}
		
		public function setLeading( fixedLeading: Number, multipliedLeading: Number ): void
		{
			_column.setLeading( fixedLeading, multipliedLeading );
		}
		
		public function get leading(): Number
		{
			return _column.leading;
		}
		
		public function get multipliedLeading(): Number
		{
			return _column.multipliedLeading;
		}
		
		public function get useBorderPadding():Boolean
		{
			return _useBorderPadding;
		}

		public function set useBorderPadding(value:Boolean):void
		{
			_useBorderPadding = value;
		}

		public function set padding( value: Number ): void {
			_paddingBottom = value;
			_paddingTop = value;
			_paddingLeft = value;
			_paddingRight = value;
		}
		
		public function get paddingBottom():Number
		{
			return _paddingBottom;
		}

		public function set paddingBottom(value:Number):void
		{
			_paddingBottom = value;
		}

		public function get effectivePaddingBottom(): Number
		{
			if ( useBorderPadding ) {
				var border: Number = borderWidthBottom/(useVariableBorders ? 1 : 2 );
				return _paddingBottom + border;
			}
			return _paddingBottom;
		}
		
		public function get paddingTop():Number
		{
			return _paddingTop;
		}

		public function set paddingTop(value:Number):void
		{
			_paddingTop = value;
		}

		public function get effectivePaddingTop(): Number
		{
			if ( useBorderPadding ) {
				var border: Number = borderWidthTop / (useVariableBorders ? 1 : 2 );
				return _paddingTop + border;
			}
			return _paddingTop;
		}
		
		public function get paddingRight():Number
		{
			return _paddingRight;
		}

		public function set paddingRight(value:Number):void
		{
			_paddingRight = value;
		}

		public function get effectivePaddingLeft(): Number
		{
			if( useBorderPadding )
			{
				var border: Number = borderWidthLeft / (useVariableBorders ? 1 : 2 );
				return _paddingLeft + border;
			}
			return _paddingLeft;
		}
		
		public function get effectivePaddingRight(): Number
		{
			if ( useBorderPadding ) {
				var border: Number = borderWidthRight / (useVariableBorders ? 1 : 2 );
				return _paddingRight + border;
			}
			return _paddingRight;
		}
		
		public function get paddingLeft():Number
		{
			return _paddingLeft;
		}

		public function set paddingLeft(value:Number):void
		{
			_paddingLeft = value;
		}

		public function get verticalAlignment():int
		{
			return _verticalAlignment;
		}

		public function set verticalAlignment(value:int):void
		{
			if( _table != null )
				_table.extendLastRow = ( value == Element.ALIGN_TOP );
			_verticalAlignment = value;
		}

		public function get horizontalAlignment(): int
		{
			return _column.alignment;
		}
		
		public function set horizontalAlignment( value: int ): void
		{
			_column.alignment = value;
		}
		
		public function get phrase():Phrase
		{
			return _phrase;
		}

		public function set phrase(value:Phrase):void
		{
			_table = null;
			_image = null;
			_phrase = value
			_column.setText( _phrase );
		}

		public function addElement( element: IElement ): void
		{
			if (_table != null) {
				_table = null;
				_column.setText(null);
			}
			_column.addElement(element);
		}
		
		/**
		 * Consumes part of the content of the cell
		 */
		internal function consumeHeight( height: Number ): void
		{
			var rightLimit: Number = getRight() - effectivePaddingRight;
			var leftLimit: Number = getLeft() + effectivePaddingLeft;
			var bry: Number = height - effectivePaddingTop - effectivePaddingBottom;
			if (rotation != 90 && rotation != 270) {
				column.setSimpleColumn(leftLimit, bry + 0.001,	rightLimit, 0);
			}
			else {
				column.setSimpleColumn(0, leftLimit, bry + 0.001, rightLimit);
			}
			try {
				column.go(true);
			} catch ( e: DocumentError )
			{
				// do nothing
				trace('error', e );
			}
		}


		
		/**
		 * Returns the height of the cell
		 * 
		 * @throws ConversionError
		 */
		public function get maxHeight(): Number
		{
			var pivoted: Boolean = (rotation == 90 || rotation == 270);
			var img: ImageElement = image;
			if (img != null) {
				img.scalePercent(100,100);
				var refWidth: Number = pivoted ? img.scaledHeight : img.scaledWidth;
				var scale: Number = ( getRight() - effectivePaddingRight - effectivePaddingLeft - getLeft()) / refWidth;
				img.scalePercent(scale * 100, scale * 100 );
				var refHeight: Number = pivoted ? img.scaledWidth : img.scaledHeight;
				setBottom(getTop() - effectivePaddingTop - effectivePaddingBottom - refHeight);
			} else 
			{
				if (pivoted && hasFixedHeight )
					setBottom(getTop() - fixedHeight);
				else {
					var ct: ColumnText = ColumnText.duplicate( column );
					var right: Number, top: Number, left: Number, bottom: Number;
					if (pivoted) {
						right = PdfPRow.RIGHT_LIMIT;
						top = getRight() - effectivePaddingRight;
						left = 0;
						bottom = getLeft() + effectivePaddingLeft;
					}
					else {
						right = noWrap ? PdfPRow.RIGHT_LIMIT : getRight() - effectivePaddingRight;
						top = getTop() - effectivePaddingTop;
						left = getLeft() + effectivePaddingLeft;
						bottom = hasFixedHeight ? top + effectivePaddingBottom - fixedHeight : PdfPRow.BOTTOM_LIMIT;
					}
					PdfPRow.setColumn(ct, left, bottom, right, top);
					try {
						ct.go(true);
					} catch ( e: DocumentError ) {
						throw new ConversionError(e);
					}
					if (pivoted)
						setBottom(getTop() - effectivePaddingTop - effectivePaddingBottom - ct.filledWidth );
					else {
						var yLine: Number = ct.yLine;
						if ( useDescender )
							yLine += ct.descender;
						setBottom(yLine - effectivePaddingBottom );
					}
				}
			}
			var height: Number = height;
			if (height < fixedHeight)
				height = fixedHeight;
			else if (height < minimumHeight )
				height = minimumHeight;
			return height;
		}
		
		static public function fromCell( cell: PdfPCell ): PdfPCell
		{
			var c: PdfPCell = new PdfPCell();
			c.llx = cell.llx;
			c.lly = cell.lly;
			c.urx = cell.urx;
			c.ury = cell.ury;
			c.cloneNonPositionParameters( cell );
			c._verticalAlignment = cell._verticalAlignment;
			c._paddingLeft = cell._paddingLeft;
			c._paddingRight = cell._paddingRight;
			c._paddingTop = cell._paddingTop;
			c._paddingBottom = cell._paddingBottom;
			c._phrase = cell._phrase;
			c._fixedHeight = cell._fixedHeight;
			c._minimumHeight = cell._minimumHeight;
			c._noWrap = cell._noWrap;
			c._colspan = cell._colspan;
			c._rowspan = cell._rowspan;
			c._cellEvent = cell._cellEvent;
			
			if( cell._table != null )
				c._table = new PdfPTable( cell._table );
			// TODO: we should clone the image
			c._image = ImageElement.getImageInstance( cell._image );
			c._cellEvent = cell.cellEvent;
			c._useDescender = cell._useDescender;
			c._column = ColumnText.duplicate(cell._column);
			c._useBorderPadding = cell._useBorderPadding;
			c._rotation = cell._rotation;
			return c;
		}

		static public function fromPhrase( phrase: Phrase ): PdfPCell
		{
			var c: PdfPCell = new PdfPCell();
			c._phrase = phrase;
			c._column.addText( c._phrase );
			c._column.setLeading( 0, 1 );
			return c;
		}
		
		static public function fromImage( image: ImageElement, fit: Boolean = false ): PdfPCell
		{
			var c: PdfPCell = new PdfPCell();
			c._borderWidth = 0.5;
			c._border = BOX;
			
			if (fit) {
				c._image = image;
				c._column.setLeading(0, 1);
				c.padding = c._borderWidth / 2;
			}
			else {
				// TODO: implements a clone method in ImageElement
				c._phrase = Phrase.fromChunk( Chunk.fromImage( image, 0, 0 ) );
				c._column.addText( c._phrase );
				c._column.setLeading(0, 1);
				c.padding = 0;
			}
			return c;
		}
	}
}