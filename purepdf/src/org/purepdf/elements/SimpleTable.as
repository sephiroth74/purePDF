/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: SimpleTable.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/SimpleTable.as $
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
	import org.purepdf.errors.BadElementError;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.interfaces.IPdfPTableEvent;

	public class SimpleTable extends RectangleElement implements IPdfPTableEvent, ITextElementaryArray
	{
		private var _alignment: int = 0;
		private var _cellpadding: Number = 0;
		private var _cellspacing: Number = 0;
		private var _widthPercentage: Number = 0;
		private var content: Vector.<SimpleCell> = new Vector.<SimpleCell>();

		public function SimpleTable()
		{
			super( 0, 0, 0, 0 );
			border = BOX;
			borderWidth = 2;
		}
		
		public function tableLayout( table: PdfPTable, widths: Vector.<Vector.<Number>>, heights: Vector.<Number>, headerRows: int, rowStart: int, canvases: Vector.<PdfContentByte> ): void
		{
			var width: Vector.<Number> = widths[0];
			var rect: RectangleElement = new RectangleElement(width[0], heights[heights.length - 1], width[width.length - 1], heights[0]);
			rect.cloneNonPositionParameters(this);
			var bd: int = rect.border;
			rect.border = RectangleElement.NO_BORDER;
			canvases[PdfPTable.BACKGROUNDCANVAS].rectangle(rect);
			rect.border = bd;
			rect.backgroundColor = null;
			canvases[PdfPTable.LINECANVAS].rectangle(rect);
		}

		public function add( o: Object ): Boolean
		{
			try
			{
				addElement( SimpleCell( o ) );
			} catch ( e: TypeError )
			{
				return false;
			} catch ( e: BadElementError )
			{
				throw new ConversionError( e );
			}
			return false;
		}

		/**
		 * Adds content to this object.
		 * @param element
		 * @throws BadElementError
		 */
		public function addElement( element: SimpleCell ): void
		{
			if ( !element.cellGroup )
				throw new BadElementError( "you can't add cells to a table directly. Add them to a row first" );
			content.push( element );
		}

		public function get alignment(): int
		{
			return _alignment;
		}

		public function set alignment( value: int ): void
		{
			_alignment = value;
		}

		public function get cellpadding(): Number
		{
			return _cellpadding;
		}

		public function set cellpadding( value: Number ): void
		{
			_cellpadding = value;
		}

		public function get cellspacing(): Number
		{
			return _cellspacing;
		}

		public function set cellspacing( value: Number ): void
		{
			_cellspacing = value;
		}

		/**
		 * Creates a PdfPTable object based on this TableAttributes object
		 * @throws DocumentError
		 */
		public function createPdfPTable(): PdfPTable
		{
			if ( content.length == 0 )
				throw new BadElementError( "trying to create a table with no rows" );
			var row: SimpleCell = content[0];
			var cell: SimpleCell;
			var columns: int = 0;
			var i: int;

			for ( i = 0; i < row.content.length; ++i )
			{
				cell = SimpleCell( row.content[i] );
				columns += cell.colspan;
			}
			var widths: Vector.<Number> = new Vector.<Number>( columns, true );
			var widthpercentages: Vector.<Number> = new Vector.<Number>( columns, true );
			var table: PdfPTable = new PdfPTable( columns );
			table.tableEvent = this;
			table.horizontalAlignment = alignment;
			var pos: int;

			for ( i = 0; i < content.length; ++i )
			{
				row = content[i];
				pos = 0;
				var j: int;

				for ( j = 0; j < row.content.length; ++j )
				{
					cell = row.content[j] as SimpleCell;

					if ( isNaN( cell.spacingLeft ) )
						cell.spacingLeft = ( cellspacing / 2 );

					if ( isNaN( cell.spacingRight ) )
						cell.spacingRight = ( cellspacing / 2 );

					if ( isNaN( cell.spacingTop ) )
						cell.spacingTop = ( cellspacing / 2 );

					if ( isNaN( cell.spacingBottom ) )
						cell.spacingBottom = cellspacing / 2;
					cell.padding = ( cellpadding );
					table.addCell( cell.createPdfPCell( row ) );

					if ( cell.colspan == 1 )
					{
						if ( cell.width > 0 )
							widths[pos] = cell.width;

						if ( cell.widthpercentage > 0 )
							widthpercentages[pos] = cell.widthpercentage;
					}
					pos += cell.colspan;
				}
			}
			var sumWidths: Number = 0;

			for ( i = 0; i < columns; i++ )
			{
				if ( widths[i] == 0 )
				{
					sumWidths = 0;
					break;
				}
				sumWidths += widths[i];
			}

			if ( sumWidths > 0 )
			{
				table.totalWidth = ( sumWidths );
				table.setNumberWidths( widths );
			} else
			{
				for ( i = 0; i < columns; i++ )
				{
					if ( widthpercentages[i] == 0 )
					{
						sumWidths = 0;
						break;
					}
					sumWidths += widthpercentages[i];
				}

				if ( sumWidths > 0 )
				{
					table.setNumberWidths( widthpercentages );
				}
			}

			if ( width > 0 )
			{
				table.totalWidth = ( width );
			}

			if ( widthPercentage > 0 )
			{
				table.widthPercentage = ( widthPercentage );
			}
			return table;
		}

		override public function get isNestable(): Boolean
		{
			return true;
		}

		override public function get type(): int
		{
			return Element.TABLE;
		}

		public function get widthPercentage(): Number
		{
			return _widthPercentage;
		}

		public function set widthPercentage( value: Number ): void
		{
			_widthPercentage = value;
		}
	}
}