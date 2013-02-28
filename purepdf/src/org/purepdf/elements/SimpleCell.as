/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: SimpleCell.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/SimpleCell.as $
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
	import org.purepdf.colors.RGBColor;
	import org.purepdf.errors.BadElementError;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.interfaces.IPdfPCellEvent;

	public class SimpleCell extends RectangleElement implements IPdfPCellEvent, ITextElementaryArray
	{
		public static const CELL: Boolean = false;
		public static const ROW: Boolean = true;
		protected var _useAscender: Boolean = false;
		protected var _useBorderPadding: Boolean;
		protected var _useDescender: Boolean = false;
		protected var _width: Number = 0;
		private var _cellgroup: Boolean = false;
		private var _colspan: uint = 1;
		private var _content: Vector.<IElement> = new Vector.<IElement>();
		private var _horizontalAlignment: int = Element.ALIGN_UNDEFINED;
		private var _paddingBottom: Number = Number.NaN;
		private var _paddingLeft: Number = Number.NaN;
		private var _paddingRight: Number = Number.NaN;
		private var _paddingTop: Number = Number.NaN;
		private var _spacingBottom: Number = Number.NaN;
		private var _spacingLeft: Number = Number.NaN;
		private var _spacingRight: Number = Number.NaN;
		private var _spacingTop: Number = Number.NaN;
		private var _verticalAlignment: int = Element.ALIGN_UNDEFINED;
		private var _widthpercentage: Number = 0;

		public function SimpleCell( row: Boolean )
		{
			super( 0, 0, 0, 0 );
			_cellgroup = row;
			border = BOX;
		}

		public function cellLayout( cell: PdfPCell, position: RectangleElement, canvases: Vector.<PdfContentByte> ): void
		{
			var sp_left: Number = _spacingLeft;
			if ( isNaN(sp_left)) sp_left = 0;
			var sp_right: Number = _spacingRight;
			if (isNaN(sp_right)) sp_right = 0;
			var sp_top: Number = _spacingTop;
			if (isNaN(sp_top)) sp_top = 0;
			var sp_bottom: Number = _spacingBottom;
			if (isNaN(sp_bottom)) sp_bottom = 0;
			
			var rect: RectangleElement = new RectangleElement( position.getLeft(sp_left), position.getBottom(sp_bottom), position.getRight(sp_right), position.getTop(sp_top));
			rect.cloneNonPositionParameters(this);
			canvases[PdfPTable.BACKGROUNDCANVAS].rectangle(rect);
			rect.backgroundColor = null;
			canvases[PdfPTable.LINECANVAS].rectangle(rect);
		}
		
		public function add( o: Object ): Boolean
		{
			try
			{
				addElement( IElement( o ) );
				return true;
			} catch ( e: TypeError )
			{
				return false;
			} catch ( e: BadElementError )
			{
				throw new ConversionError( e );
			}
			return false;
		}
		
		override public function get type():int
		{
			return Element.CELL;
		}

		/**
		 * @throws BadElementError
		 */
		public function addElement( element: IElement ): void
		{
			if ( _cellgroup )
			{
				if ( element is SimpleCell )
				{
					if ( SimpleCell( element ).cellGroup )
					{
						throw new BadElementError( "you can't add one row to another row" );
					}
					_content.push( element );
					return;
				} else
				{
					throw new BadElementError( "you can only add cells to rows" );
				}
			}

			if ( element.type == Element.PARAGRAPH || element.type == Element.PHRASE || element.type == Element.ANCHOR || element.
							type == Element.CHUNK || element.type == Element.LIST || element.type == Element.MARKED || element.
							type == Element.JPEG || element.type == Element.JPEG2000 || element.type == Element.JBIG2 || element.
							type == Element.IMGRAW || element.type == Element.IMGTEMPLATE )
			{
				_content.push( element );
			} else
			{
				throw new BadElementError( "you can't add an element of type " + element.type + " to a SimpleCell" );
			}
		}

		public function get cellGroup(): Boolean
		{
			return _cellgroup;
		}

		public function set cellGroup( value: Boolean ): void
		{
			_cellgroup = value;
		}

		public function get colspan(): uint
		{
			return _colspan;
		}

		public function set colspan( value: uint ): void
		{
			_colspan = value;
		}

		public function get content(): Vector.<IElement>
		{
			return _content;
		}

		/**
		 * Creates a PdfPCell with these attributes.
		 */
		public function createPdfPCell( rowAttributes: SimpleCell ): PdfPCell
		{
			var cell: PdfPCell = new PdfPCell();
			cell.border = NO_BORDER;
			var tmp: SimpleCell = new SimpleCell( CELL );
			tmp.spacingLeft = _spacingLeft;
			tmp.spacingRight = _spacingRight;
			tmp.spacingTop = _spacingTop;
			tmp.spacingBottom = _spacingBottom;
			tmp.cloneNonPositionParameters( rowAttributes );
			tmp.softCloneNonPositionParameters( this );
			cell.cellEvent = tmp;
			cell.horizontalAlignment = rowAttributes.horizontalAlignment;
			cell.verticalAlignment = rowAttributes.verticalAlignment;
			cell.useAscender = rowAttributes.useAscender;
			cell.useBorderPadding = rowAttributes.useBorderPadding;
			cell.useDescender = rowAttributes.useDescender;
			cell.colspan = _colspan;

			if ( horizontalAlignment != Element.ALIGN_UNDEFINED )
				cell.horizontalAlignment = horizontalAlignment;

			if ( verticalAlignment != Element.ALIGN_UNDEFINED )
				cell.verticalAlignment = verticalAlignment;

			if ( useAscender )
				cell.useAscender = useAscender;

			if ( useBorderPadding )
				cell.useBorderPadding = useBorderPadding;

			if ( useDescender )
				cell.useDescender = useDescender;
			var p: Number;
			var sp_left: Number = _spacingLeft;

			if ( isNaN( sp_left ) )
				sp_left = 0;
			var sp_right: Number = _spacingRight;

			if ( isNaN( sp_right ) )
				sp_right = 0;
			var sp_top: Number = _spacingTop;

			if ( isNaN( sp_top ) )
				sp_top = 0;
			var sp_bottom: Number = _spacingBottom;

			if ( isNaN( sp_bottom ) )
				sp_bottom = 0;
			p = _paddingLeft;

			if ( isNaN( p ) )
				p = 0;
			cell.paddingLeft = ( p + sp_left );
			p = _paddingRight;

			if ( isNaN( p ) )
				p = 0;
			cell.paddingRight = ( p + sp_right );
			p = _paddingTop;

			if ( isNaN( p ) )
				p = 0;
			cell.paddingTop = p + sp_top;
			p = _paddingBottom;

			if ( isNaN( p ) )
				p = 0;
			cell.paddingBottom = ( p + sp_bottom );

			for ( var i: int = 0; i < _content.length; ++i )
			{
				cell.addElement( _content[i] );
			}
			return cell;
		}

		public function get horizontalAlignment(): int
		{
			return _horizontalAlignment;
		}

		public function set horizontalAlignment( value: int ): void
		{
			_horizontalAlignment = value;
		}

		/**
		 * Sets the padding parameters if they are undefined.
		 * @param padding
		 */
		public function set padding( value: Number ): void
		{
			if ( isNaN( _paddingRight ) )
				paddingRight = value;

			if ( isNaN( _paddingLeft ) )
				paddingLeft = value;

			if ( isNaN( _paddingTop ) )
				paddingTop = value;

			if ( isNaN( _paddingBottom ) )
				paddingBottom = value;
		}

		public function get paddingBottom(): Number
		{
			return _paddingBottom;
		}

		public function set paddingBottom( value: Number ): void
		{
			_paddingBottom = value;
		}

		public function get paddingLeft(): Number
		{
			return _paddingLeft;
		}

		public function set paddingLeft( value: Number ): void
		{
			_paddingLeft = value;
		}

		public function get paddingRight(): Number
		{
			return _paddingRight;
		}

		public function set paddingRight( value: Number ): void
		{
			_paddingRight = value;
		}

		public function get paddingTop(): Number
		{
			return _paddingTop;
		}

		public function set paddingTop( value: Number ): void
		{
			_paddingTop = value;
		}

		public function set spacing( value: Number ): void
		{
			_spacingBottom = value;
			_spacingLeft = value;
			_spacingRight = value;
			_spacingTop = value;
		}

		public function get spacingBottom(): Number
		{
			return _spacingBottom;
		}

		public function set spacingBottom( value: Number ): void
		{
			_spacingBottom = value;
		}

		public function get spacingLeft(): Number
		{
			return _spacingLeft;
		}

		public function set spacingLeft( value: Number ): void
		{
			_spacingLeft = value;
		}

		public function get spacingRight(): Number
		{
			return _spacingRight;
		}

		public function set spacingRight( value: Number ): void
		{
			_spacingRight = value;
		}

		public function get spacingTop(): Number
		{
			return _spacingTop;
		}

		public function set spacingTop( value: Number ): void
		{
			_spacingTop = value;
		}

		public function get useAscender(): Boolean
		{
			return _useAscender;
		}

		public function set useAscender( value: Boolean ): void
		{
			_useAscender = value;
		}

		public function get useBorderPadding(): Boolean
		{
			return _useBorderPadding;
		}

		public function set useBorderPadding( value: Boolean ): void
		{
			_useBorderPadding = value;
		}

		public function get useDescender(): Boolean
		{
			return _useDescender;
		}

		public function set useDescender( value: Boolean ): void
		{
			_useDescender = value;
		}

		public function get verticalAlignment(): int
		{
			return _verticalAlignment;
		}

		public function set verticalAlignment( value: int ): void
		{
			_verticalAlignment = value;
		}

		override public function get width(): Number
		{
			return _width;
		}

		public function set width( value: Number ): void
		{
			_width = value;
		}

		public function get widthpercentage(): Number
		{
			return _widthpercentage;
		}

		public function set widthpercentage( value: Number ): void
		{
			_widthpercentage = value;
		}
	}
}