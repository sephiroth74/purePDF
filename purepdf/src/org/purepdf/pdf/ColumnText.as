/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: ColumnText.as 362 2010-05-05 16:53:53Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 362 $ $LastChangedDate: 2010-05-05 12:53:53 -0400 (Wed, 05 May 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/ColumnText.as $
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
	import org.purepdf.elements.List;
	import org.purepdf.elements.ListItem;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.SimpleTable;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.errors.NullPointerError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.utils.assert_true;
	import org.purepdf.utils.pdf_core;

	public class ColumnText
	{
		public static const GLOBAL_SPACE_CHAR_RATIO: Number = 0;
		public static const NO_MORE_COLUMN: int = 2;
		public static const NO_MORE_TEXT: int = 1;
		public static const START_COLUMN: int = 0;
		protected const LINE_STATUS_NOLINE: int = 2;
		protected const LINE_STATUS_OFFLIMITS: int = 1;
		protected const LINE_STATUS_OK: int = 0;
		protected var _alignment: int = Element.ALIGN_LEFT;
		protected var _canvas: PdfContentByte;
		protected var _canvases: Vector.<PdfContentByte>;
		protected var _descender: Number = 0;
		protected var _extraParagraphSpace: Number = 0;
		protected var _followingIndent: Number = 0;
		protected var _indent: Number = 0;
		protected var _multipliedLeading: Number = 0;
		protected var _rightIndent: Number = 0;
		protected var _runDirection: int = PdfWriter.RUN_DIRECTION_DEFAULT;
		protected var _yLine: Number = 0;
		protected var bidiLine: BidiLine;
		protected var composite: Boolean = false;
		protected var compositeColumn: ColumnText;
		protected var compositeElements: Vector.<IElement>;
		protected var currentLeading: Number = 16;
		protected var fixedLeading: Number = 16;
		protected var leftWall: Vector.<Vector.<Number>>;
		protected var leftX: Number = 0;
		protected var lineStatus: int = 0;
		protected var listIdx: int = 0;
		protected var maxY: Number = 0;
		protected var minY: Number = 0;
		protected var rectangularMode: Boolean = false;
		protected var rectangularWidth: Number = -1;
		protected var rightWall: Vector.<Vector.<Number>>;
		protected var rightX: Number = 0;
		protected var waitPhrase: Phrase;
		private var _filledWidth: Number = 0;
		private var _useAscender: Boolean = false;
		private var adjustFirstLine: Boolean = true;
		private var _arabicOptions: int = 0;
		private var firstLineY: Number = 0;
		private var firstLineYDone: Boolean = false;
		private var lastWasNewline: Boolean = true;
		private var linesWritten: int = 0;
		private var _spaceCharRatio: Number = GLOBAL_SPACE_CHAR_RATIO;
		private var splittedRow: Boolean;

		public function ColumnText( content: PdfContentByte )
		{
			_canvas = content;
		}

		public function get spaceCharRatio():Number
		{
			return _spaceCharRatio;
		}

		/**
		 * 
		 * @see #GLOBAL_SPACE_CHAR_RATIO
		 */
		public function set spaceCharRatio(value:Number):void
		{
			_spaceCharRatio = value;
		}

		pdf_core function setSimpleVars( org: ColumnText ): void
		{
			maxY = org.maxY;
			minY = org.minY;
			_alignment = org._alignment;
			leftWall = null;
			if (org.leftWall != null)
				leftWall = org.leftWall.concat();
			rightWall = null;
			if (org.rightWall != null)
				rightWall = org.rightWall.concat();
			_yLine = org._yLine;
			currentLeading = org.currentLeading;
			fixedLeading = org.fixedLeading;
			_multipliedLeading = org._multipliedLeading;
			_canvas = org._canvas;
			_canvases = org._canvases;
			lineStatus = org.lineStatus;
			_indent = org._indent;
			_followingIndent = org._followingIndent;
			_rightIndent = org._rightIndent;
			_extraParagraphSpace = org._extraParagraphSpace;
			rectangularWidth = org.rectangularWidth;
			rectangularMode = org.rectangularMode;
			_spaceCharRatio = org.spaceCharRatio;
			lastWasNewline = org.lastWasNewline;
			linesWritten = org.linesWritten;
			_arabicOptions = org._arabicOptions;
			_runDirection = org._runDirection;
			_descender = org._descender;
			composite = org.composite;
			splittedRow = org.splittedRow;
			
			if (org.composite) {
				compositeElements = org.compositeElements.concat();
				if (splittedRow) 
				{
					var table: PdfPTable = compositeElements[0] as PdfPTable;
					compositeElements[0] = new PdfPTable(table);
				}
				if (org.compositeColumn != null)
					compositeColumn = duplicate(org.compositeColumn);
			}
			
			listIdx = org.listIdx;
			firstLineY = org.firstLineY;
			leftX = org.leftX;
			rightX = org.rightX;
			firstLineYDone = org.firstLineYDone;
			waitPhrase = org.waitPhrase;
			useAscender = org.useAscender;
			filledWidth = org.filledWidth;
			adjustFirstLine = org.adjustFirstLine;
		}
		
		/**
		 * Adds an element. Supported elements are Paragraph,
		 * List, PdfPTable, ImageElement and
		 * Graphic.<br/>
		 * It removes all the text placed with addText().
		 *
		 */
		public function addElement( element: IElement ): void
		{
			if ( element == null )
				return;

			if ( element is ImageElement )
			{
				var img: ImageElement = ImageElement( element );
				var t: PdfPTable = new PdfPTable( 1 );
				var w: Number = img.widthPercentage;

				if ( w == 0 )
				{
					t.totalWidth = img.scaledWidth;
					t.lockedWidth = true;
				} else
					t.widthPercentage = w;
				t.spacingAfter = img.spacingAfter;
				t.spacingBefore = img.spacingBefore;

				switch ( img.alignment )
				{
					case ImageElement.LEFT:
						t.horizontalAlignment = Element.ALIGN_LEFT;
						break;
					case ImageElement.RIGHT:
						t.horizontalAlignment = Element.ALIGN_RIGHT;
						break;
					default:
						t.horizontalAlignment = Element.ALIGN_CENTER;
						break;
				}
				var c: PdfPCell = PdfPCell.fromImage( img, true );
				c.padding = 0;
				c.border = img.border;
				c.borderColor = img.borderColor;
				c.borderWidth = img.borderWidth;
				c.backgroundColor = img.backgroundColor;
				t.addCell( c );
				element = t;
			}

			if ( element.type == Element.CHUNK )
			{
				element = Paragraph.fromChunk( Chunk( element ) );
			} else if ( element.type == Element.PHRASE )
			{
				element = Paragraph.fromPhrase( Phrase( element ) );
			}

			if ( element is SimpleTable )
			{
				//throw new NonImplementatioError( "SimpleTable not yet implemented" );
				element = SimpleTable(element).createPdfPTable();
			} else if ( element.type != Element.PARAGRAPH && element.type != Element.LIST && element.type != Element.PTABLE &&
							element.type != Element.YMARK )
			{
				throw new ArgumentError( "element not allowed" );
			}

			if ( !composite )
			{
				composite = true;
				compositeElements = new Vector.<IElement>();
				bidiLine = null;
				waitPhrase = null;
			}
			compositeElements.push( element );
		}

		public function addText( phrase: Phrase ): void
		{
			if ( phrase == null || composite )
				return;
			addWaitingPhrase();

			if ( bidiLine == null )
			{
				waitPhrase = phrase;
				return;
			}
			var chunks: Vector.<Object> = phrase.getChunks();

			for ( var k: int = 0; k < chunks.length; ++k )
				bidiLine.addChunk( PdfChunk.fromChunk( Chunk( chunks[k] ), null ) );
		}
		
		/**
		 * 
		 * @see Chunk
		 */
		public function addChunk( chunk: Chunk ): void
		{
			if( chunk == null || composite )
				return;
			addText( Phrase.fromChunk( chunk ) );
		}
		
		/**
		 * Gets the width that the line will occupy after writing.
		 * Only the width of the first line is returned.
		 */    
		public static function getWidth( phrase: Phrase, runDirection: int, arabicOptions: int ): Number
		{
			var ct: ColumnText = new ColumnText(null);
			ct.addText(phrase);
			ct.addWaitingPhrase();
			var line: PdfLine = ct.bidiLine.processLine(0, 20000, Element.ALIGN_LEFT, runDirection, arabicOptions);
			if (line == null)
				return 0;
			else
				return 20000 - line.widthLeft;
		}

		public function get alignment(): int
		{
			return _alignment;
		}

		/**
		 * 
		 * @see org.purepdf.elements.Element#ALIGN_RIGHT
		 * @see org.purepdf.elements.Element#ALIGN_CENTER
		 * @see org.purepdf.elements.Element#ALIGN_JUSTIFIED
		 * @see org.purepdf.elements.Element#ALIGN_LEFT
		 */
		public function set alignment( value: int ): void
		{
			_alignment = value;
		}

		public function get canvas(): PdfContentByte
		{
			return _canvas;
		}

		public function set canvas( value: PdfContentByte ): void
		{
			_canvas = value;
			_canvases = null;

			if ( compositeColumn != null )
				compositeColumn.canvas = value;
		}

		public function get canvases(): Vector.<PdfContentByte>
		{
			return _canvases;
		}

		public function set canvases( value: Vector.<PdfContentByte> ): void
		{
			_canvases = value;
			_canvas = _canvases[PdfPTable.TEXTCANVAS];

			if ( compositeColumn != null )
				compositeColumn.canvases = value;
		}

		public function get descender(): Number
		{
			return _descender;
		}

		public function get extraParagraphSpace(): Number
		{
			return _extraParagraphSpace;
		}

		public function set extraParagraphSpace( value: Number ): void
		{
			_extraParagraphSpace = value;
		}

		public function get filledWidth(): Number
		{
			return _filledWidth;
		}

		public function set filledWidth( value: Number ): void
		{
			_filledWidth = value;
		}

		public function get followingIndent(): Number
		{
			return _followingIndent;
		}

		public function set followingIndent( value: Number ): void
		{
			_followingIndent = value;
			lastWasNewline = true;
		}

		/**
		 * Outputs the lines to the document. The output can be simulated
		 *
		 * @throws DocumentError
		 */
		public function go( simulate: Boolean = false ): int
		{
			if ( composite )
				return goComposite( simulate );
			addWaitingPhrase();

			if ( bidiLine == null )
				return NO_MORE_TEXT;
			_descender = 0;
			linesWritten = 0;
			var dirty: Boolean = false;
			var ratio: Number = _spaceCharRatio;
			var currentValues: Vector.<Object> = new Vector.<Object>( 2, true );
			var currentFont: PdfFont = null;
			var lastBaseFactor: Number = 0;
			currentValues[1] = lastBaseFactor;
			var pdf: PdfDocument = null;
			var graphics: PdfContentByte = null;
			var text: PdfContentByte = null;
			var firstLineY: Number = Number.NaN;
			var localRunDirection: int = PdfWriter.RUN_DIRECTION_NO_BIDI;

			if ( _runDirection != PdfWriter.RUN_DIRECTION_DEFAULT )
				localRunDirection = _runDirection;

			if ( _canvas != null )
			{
				graphics = _canvas;
				pdf = _canvas.pdfDocument;
				text = _canvas.duplicate();
			} else if ( !simulate )
				throw new NullPointerError( "column text go with simulate == false and text == null" );

			if ( !simulate )
			{
				if ( ratio == GLOBAL_SPACE_CHAR_RATIO )
					ratio = text.writer.spaceCharRatio;
				else if ( ratio < 0.001 )
					ratio = 0.001;
			}
			var firstIndent: Number = 0;
			var line: PdfLine;
			var x1: Number;
			var status: int = 0;

			while ( true )
			{
				firstIndent = ( lastWasNewline ? _indent : _followingIndent ); //

				if ( rectangularMode )
				{
					if ( rectangularWidth <= firstIndent + _rightIndent )
					{
						status = NO_MORE_COLUMN;

						if ( bidiLine.isEmpty )
							status |= NO_MORE_TEXT;
						break;
					}

					if ( bidiLine.isEmpty )
					{
						status = NO_MORE_TEXT;
						break;
					}
					line = bidiLine.processLine( leftX, rectangularWidth - firstIndent - _rightIndent, _alignment,
									localRunDirection,
									_arabicOptions );

					if ( line == null )
					{
						status = NO_MORE_TEXT;
						break;
					}
					var maxSize: Vector.<Number> = line.getMaxSize();

					if ( useAscender && isNaN( firstLineY ) )
						currentLeading = line.ascender;
					else
						currentLeading = Math.max( fixedLeading + maxSize[0] * _multipliedLeading, maxSize[1] );

					if ( _yLine > maxY || _yLine - currentLeading < minY )
					{
						status = NO_MORE_COLUMN;
						bidiLine.restore();
						break;
					}
					_yLine -= currentLeading;

					if ( !simulate && !dirty )
					{
						text.beginText();
						dirty = true;
					}

					if ( isNaN( firstLineY ) )
						firstLineY = _yLine;
					updateFilledWidth( rectangularWidth - line.widthLeft );
					x1 = leftX;
				} else
				{
					var yTemp: Number = _yLine;
					var xx: Vector.<Number> = findLimitsTwoLines();

					if ( xx == null )
					{
						status = NO_MORE_COLUMN;

						if ( bidiLine.isEmpty )
							status |= NO_MORE_TEXT;
						_yLine = yTemp;
						break;
					}

					if ( bidiLine.isEmpty )
					{
						status = NO_MORE_TEXT;
						_yLine = yTemp;
						break;
					}
					x1 = Math.max( xx[0], xx[2] );
					var x2: Number = Math.min( xx[1], xx[3] );

					if ( x2 - x1 <= firstIndent + _rightIndent )
						continue;

					if ( !simulate && !dirty )
					{
						text.beginText();
						dirty = true;
					}
					line = bidiLine.processLine( x1, x2 - x1 - firstIndent - _rightIndent, _alignment, localRunDirection,
									_arabicOptions );

					if ( line == null )
					{
						status = NO_MORE_TEXT;
						_yLine = yTemp;
						break;
					}
				}

				if ( !simulate )
				{
					currentValues[0] = currentFont;
					text.setTextMatrix( 1, 0, 0, 1, x1 + ( line.isRTL ? _rightIndent : firstIndent ) + line.pdf_core::indentLeft,
									_yLine );
					pdf.pdf_core::writeLineToContent( line, text, graphics, currentValues, ratio );
					currentFont = currentValues[0] as PdfFont;
				}
				lastWasNewline = line.isNewlineSplit;
				_yLine -= line.isNewlineSplit ? _extraParagraphSpace : 0;
				++linesWritten;
				_descender = line.descender;
			}

			if ( dirty )
			{
				text.endText();
				_canvas.addContent( text );
			}
			return status;
		}

		/**
		 * Checks if the element has a height of 0.
		 */
		public function get hasZeroHeightElement(): Boolean
		{
			return composite && !( compositeElements.length == 0 ) && compositeElements[0].type == Element.YMARK;
		}

		public function get indent(): Number
		{
			return _indent;
		}

		public function set indent( value: Number ): void
		{
			_indent = value;
			lastWasNewline = true;
		}

		public function get leading(): Number
		{
			return fixedLeading;
		}

		public function get multipliedLeading(): Number
		{
			return _multipliedLeading;
		}

		public function get rightIndent(): Number
		{
			return _rightIndent;
		}

		public function set rightIndent( value: Number ): void
		{
			_rightIndent = value;
			lastWasNewline = true;
		}

		public function get runDirection(): int
		{
			return _runDirection;
		}

		/**
		 * 
		 * @see org.purepdf.pdf.PdfWriter#RUN_DIRECTION_DEFAULT
		 * @see org.purepdf.pdf.PdfWriter#RUN_DIRECTION_RTL
		 * @see org.purepdf.pdf.PdfWriter#RUN_DIRECTION_LTR
		 * @see org.purepdf.pdf.PdfWriter#RUN_DIRECTION_NO_BIDI
		 */
		public function set runDirection( value: int ): void
		{
			if ( value < PdfWriter.RUN_DIRECTION_DEFAULT || value > PdfWriter.RUN_DIRECTION_RTL )
				throw new RuntimeError( "invalid run direction" );
			_runDirection = value;
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
			_arabicOptions = value;
		}

		public function setACopy( org: ColumnText ): void
		{
			setSimpleVars( org );

			if ( org.bidiLine != null )
				bidiLine = BidiLine.fromBidiLine( org.bidiLine );
		}

		public function setAlignment( value: int ): void
		{
			_alignment = value;
		}

		public function setLeading( leading: Number, mul: Number = 0 ): void
		{
			fixedLeading = leading;
			_multipliedLeading = mul;
		}

		/**
		 * Simplified method for rectangular columns.
		 * 
		 * @param llx
		 * @param lly
		 * @param urx
		 * @param ury
		 */
		public function setSimpleColumn( llx: Number, lly: Number, urx: Number, ury: Number ): void
		{
			leftX = Math.min( llx, urx );
			maxY = Math.max( lly, ury );
			minY = Math.min( lly, ury );
			rightX = Math.max( llx, urx );
			_yLine = maxY;
			rectangularWidth = rightX - leftX;

			if ( rectangularWidth < 0 )
				rectangularWidth = 0;
			rectangularMode = true;
		}
		
		/**
		 * Simplified method for rectangular columns.
		 * 
		 * @param llx the lower left x corner
		 * @param lly the lower left y corner
		 * @param urx the upper right x corner
		 * @param ury the upper right y corner
		 * @param leading the leading
		 * @param alignment the column alignment
		 */
		public function setSimpleColumn2( llx: Number, lly: Number, urx: Number, ury: Number, leading: Number, alignment: int ): void
		{
			setLeading( leading );
			this.alignment = alignment;
			setSimpleColumn( llx, lly, urx, ury );
		}
		
		/**
		 * Sets the columns bounds. Each column bound is described by a
		 * Vector.&lt;Number&gt; with the line points [x1,y1,x2,y2,...].
		 * The array must have at least 4 elements.
		 * 
		 */
		public function setColumns( leftLine: Vector.<Number>, rightLine: Vector.<Number> ): void
		{
			maxY = -10e20;
			minY = 10e20;
			yLine = Math.max( leftLine[1], leftLine[leftLine.length - 1] );
			rightWall = convertColumn(rightLine);
			leftWall = convertColumn(leftLine);
			rectangularWidth = -1;
			rectangularMode = false;
		}

		/**
		 * Converts a sequence of lines representing one of the column bounds into
		 * an internal format.
		 * 
		 * @throws AssertionError
		 * @throws RuntimeError
		 */
		protected function convertColumn( cLine: Vector.<Number> ): Vector.<Vector.<Number>>
		{
			assert_true( cLine.length >= 4, "parameter cLine must be length >= 4");
			
			var cc: Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
			var k: int;
			var x1: Number;
			var x2: Number;
			var y1: Number;
			var y2: Number;
			var a: Number;
			var b: Number;
			var r: Vector.<Number>;
			
			for( k = 0; k < cLine.length - 2; k += 2 )
			{
				x1 = cLine[k];
				y1 = cLine[k + 1];
				x2 = cLine[k + 2];
				y2 = cLine[k + 3];
				if (y1 == y2)
					continue;
				
				a = (x1 - x2) / (y1 - y2);
				b = x1 - a * y1;
				r = new Vector.<Number>( 4, true );
				r[0] = Math.min(y1, y2);
				r[1] = Math.max(y1, y2);
				r[2] = a;
				r[3] = b;
				cc.push(r);
				maxY = Math.max(maxY, r[1]);
				minY = Math.min(minY, r[0]);
			}
			
			if( cc.length == 0 )
				throw new RuntimeError( "no valid column line found" );
			return cc;
		}
		
		
		public function setText( phrase: Phrase ): void
		{
			bidiLine = null;
			composite = false;
			compositeColumn = null;
			compositeElements = null;
			listIdx = 0;
			splittedRow = false;
			waitPhrase = phrase;
		}

		public function updateFilledWidth( w: Number ): void
		{
			if ( w > _filledWidth )
				_filledWidth = w;
		}

		/**
		 * Simplified method for rectangular columns
		 */
		public function get useAscender(): Boolean
		{
			return _useAscender;
		}

		public function set useAscender( value: Boolean ): void
		{
			_useAscender = value;
		}

		public function get yLine(): Number
		{
			return _yLine;
		}

		public function set yLine( value: Number ): void
		{
			_yLine = value;
		}

		/**
		 * Finds the intersection between the yLine and the two
		 * column bounds
		 */
		protected function findLimitsOneLine(): Vector.<Number>
		{
			var x1: Number = findLimitsPoint( leftWall );

			if ( lineStatus == LINE_STATUS_OFFLIMITS || lineStatus == LINE_STATUS_NOLINE )
				return null;
			var x2: Number = findLimitsPoint( rightWall );

			if ( lineStatus == LINE_STATUS_NOLINE )
				return null;
			return Vector.<Number>( [x1, x2] );
		}

		/**
		 * Finds the intersection between the yLine and the column
		 */
		protected function findLimitsPoint( wall: Vector.<Vector.<Number>> ): Number
		{
			lineStatus = LINE_STATUS_OK;

			if ( _yLine < minY || _yLine > maxY )
			{
				lineStatus = LINE_STATUS_OFFLIMITS;
				return 0;
			}

			for ( var k: int = 0; k < wall.length; ++k )
			{
				var r: Vector.<Number> = wall[k];

				if ( _yLine < r[0] || _yLine > r[1] )
					continue;
				return r[2] * _yLine + r[3];
			}
			lineStatus = LINE_STATUS_NOLINE;
			return 0;
		}

		/**
		 * Finds the intersection between the yLine,
		 * the yLine-leading and the two column bounds
		 */
		protected function findLimitsTwoLines(): Vector.<Number>
		{
			var repeat: Boolean = false;

			for ( ; ;  )
			{
				if ( repeat && currentLeading == 0 )
					return null;
				repeat = true;
				var x1: Vector.<Number> = findLimitsOneLine();

				if ( lineStatus == LINE_STATUS_OFFLIMITS )
					return null;
				_yLine -= currentLeading;

				if ( lineStatus == LINE_STATUS_NOLINE )
					continue;
				var x2: Vector.<Number> = findLimitsOneLine();

				if ( lineStatus == LINE_STATUS_OFFLIMITS )
					return null;

				if ( lineStatus == LINE_STATUS_NOLINE )
				{
					_yLine -= currentLeading;
					continue;
				}

				if ( x1[0] >= x2[1] || x2[0] >= x1[1] )
					continue;
				return Vector.<Number>( [x1[0], x1[1], x2[0], x2[1]] );
			}
			return null;
		}

		/**
		 * @throws DocumentError
		 */
		protected function goComposite( simulate: Boolean ): int
		{
			if ( !rectangularMode )
				throw new DocumentError( "irregular columns are not supported in composite mode" );
			linesWritten = 0;
			_descender = 0;
			var firstPass: Boolean = adjustFirstLine;
			var k: int;
			var i: int;
			var status: int;
			var keep: int;
			var lastY: Number;
			var createHere: Boolean;
			var keepCandidate: Boolean;
			var rowHeight: Number;

			//main_loop:
			
			var main_loop: Boolean = false;
			
			while ( true )
			{
				main_loop = false;
				
				if ( compositeElements.length == 0 )
					return NO_MORE_TEXT;
				var element: IElement = IElement( compositeElements[0] );

				if ( element.type == Element.PARAGRAPH )
				{
					var para: Paragraph = Paragraph( element );
					status = 0;

					for ( keep = 0; keep < 2; ++keep )
					{
						lastY = _yLine;
						createHere = false;

						if ( compositeColumn == null )
						{
							compositeColumn = new ColumnText( canvas );
							compositeColumn.useAscender = firstPass ? _useAscender : false;
							compositeColumn.alignment = para.alignment;
							compositeColumn.indent = para.indentationLeft + para.firstLineIndent;
							compositeColumn.extraParagraphSpace = para.extraParagraphSpace;
							compositeColumn.followingIndent = para.indentationLeft;
							compositeColumn.rightIndent = para.indentationRight;
							compositeColumn.setLeading( para.leading, para.multipliedLeading );
							compositeColumn._runDirection = _runDirection;
							compositeColumn._arabicOptions = _arabicOptions;
							compositeColumn._spaceCharRatio = _spaceCharRatio;
							compositeColumn.addText( para );

							if ( !firstPass )
							{
								_yLine -= para.spacingBefore;
							}
							createHere = true;
						}
						compositeColumn.leftX = leftX;
						compositeColumn.rightX = rightX;
						compositeColumn.yLine = _yLine;
						compositeColumn.rectangularWidth = rectangularWidth;
						compositeColumn.rectangularMode = rectangularMode;
						compositeColumn.minY = minY;
						compositeColumn.maxY = maxY;
						keepCandidate = ( para.keeptogether && createHere && !firstPass );
						status = compositeColumn.go( simulate || ( keepCandidate && keep == 0 ) );
						updateFilledWidth( compositeColumn.filledWidth );

						if ( ( status & NO_MORE_TEXT ) == 0 && keepCandidate )
						{
							compositeColumn = null;
							_yLine = lastY;
							return NO_MORE_COLUMN;
						}

						if ( simulate || !keepCandidate )
							break;

						if ( keep == 0 )
						{
							compositeColumn = null;
							_yLine = lastY;
						}
					}
					firstPass = false;
					_yLine = compositeColumn.yLine;
					linesWritten += compositeColumn.linesWritten;
					_descender = compositeColumn.descender;

					if ( ( status & NO_MORE_TEXT ) != 0 )
					{
						compositeColumn = null;
						compositeElements.shift();
						_yLine -= para.spacingAfter;
					}

					if ( ( status & NO_MORE_COLUMN ) != 0 )
					{
						return NO_MORE_COLUMN;
					}
				} else if ( element.type == Element.LIST )
				{
					var list: List = List( element );
					var items: Vector.<IElement> = list.items;
					var item: ListItem = null;
					var listIndentation: Number = list.indentationLeft;
					var count: int = 0;
					var stack: Vector.<Vector.<Object>> = new Vector.<Vector.<Object>>();

					for ( k = 0; k < items.length; ++k )
					{
						var obj: Object = items[k];

						if ( obj is ListItem )
						{
							if ( count == listIdx )
							{
								item = ListItem( obj );
								break;
							} else
								++count;
						} else if ( obj is List )
						{
							stack.push( Vector.<Object>( [list, k, listIndentation] ) );
							list = List( obj );
							items = list.items;
							listIndentation += list.indentationLeft;
							k = -1;
							continue;
						}

						if ( k == items.length - 1 )
						{
							if ( stack.length > 0 )
							{
								var objs: Vector.<Object> = Vector.<Object>( stack.pop() );
								list = List( objs[0] );
								items = list.items;
								k = int( objs[1] );
								listIndentation = Number( objs[2] );
							}
						}
					}
					status = 0;

					for ( keep = 0; keep < 2; ++keep )
					{
						lastY = _yLine;
						createHere = false;

						if ( compositeColumn == null )
						{
							if ( item == null )
							{
								listIdx = 0;
								compositeElements.shift();
								
								trace( 'continue main_loop' );
								
								main_loop = true;
								//continue main_loop;
								break;
							}
							compositeColumn = new ColumnText( canvas );
							compositeColumn.useAscender = ( firstPass ? _useAscender : false );
							compositeColumn.alignment = item.alignment;
							compositeColumn.indent = item.indentationLeft + listIndentation + item.firstLineIndent;
							compositeColumn.extraParagraphSpace = item.extraParagraphSpace;
							compositeColumn.followingIndent = compositeColumn.indent;
							compositeColumn.rightIndent = item.indentationRight + list.indentationRight;
							compositeColumn.setLeading( item.leading, item.multipliedLeading );
							compositeColumn._runDirection = _runDirection;
							compositeColumn._arabicOptions = _arabicOptions;
							compositeColumn._spaceCharRatio = _spaceCharRatio;
							compositeColumn.addText( item );

							if ( !firstPass )
							{
								_yLine -= item.spacingBefore;
							}
							createHere = true;
						}
						compositeColumn.leftX = leftX;
						compositeColumn.rightX = rightX;
						compositeColumn.yLine = _yLine;
						compositeColumn.rectangularWidth = rectangularWidth;
						compositeColumn.rectangularMode = rectangularMode;
						compositeColumn.minY = minY;
						compositeColumn.maxY = maxY;
						keepCandidate = ( item.keeptogether && createHere && !firstPass );
						status = compositeColumn.go( simulate || ( keepCandidate && keep == 0 ) );
						updateFilledWidth( compositeColumn.filledWidth );

						if ( ( status & NO_MORE_TEXT ) == 0 && keepCandidate )
						{
							compositeColumn = null;
							_yLine = lastY;
							return NO_MORE_COLUMN;
						}

						if ( simulate || !keepCandidate )
							break;

						if ( keep == 0 )
						{
							compositeColumn = null;
							_yLine = lastY;
						}
					}
					
					if( main_loop )
						continue;
					
					firstPass = false;
					_yLine = compositeColumn.yLine;
					linesWritten += compositeColumn.linesWritten;
					_descender = compositeColumn.descender;

					if ( !isNaN( compositeColumn.firstLineY ) && !compositeColumn.firstLineYDone )
					{
						if ( !simulate )
							showTextAligned( canvas, Element.ALIGN_LEFT, Phrase.fromChunk( item.listSymbol ), compositeColumn.
											leftX + listIndentation, compositeColumn.firstLineY, 0 );
						compositeColumn.firstLineYDone = true;
					}

					if ( ( status & NO_MORE_TEXT ) != 0 )
					{
						compositeColumn = null;
						++listIdx;
						_yLine -= item.spacingAfter;
					}

					if ( ( status & NO_MORE_COLUMN ) != 0 )
						return NO_MORE_COLUMN;
				} else if ( element.type == Element.PTABLE )
				{
					if ( _yLine < minY || _yLine > maxY )
						return NO_MORE_COLUMN;
					var table: PdfPTable = PdfPTable( element );

					if ( table.size <= table.headerRows )
					{
						compositeElements.shift();
						continue;
					}
					var yTemp: Number = _yLine;

					if ( !firstPass && listIdx == 0 )
						yTemp -= table.spacingBefore;
					var yLineWrite: Number = yTemp;

					if ( yTemp < minY || yTemp > maxY )
						return NO_MORE_COLUMN;
					currentLeading = 0;
					var x1: Number = leftX;
					var tableWidth: Number;

					if ( table.lockedWidth )
					{
						tableWidth = table.totalWidth;
						updateFilledWidth( tableWidth );
					} else
					{
						tableWidth = rectangularWidth * table.widthPercentage / 100;
						table.totalWidth = tableWidth;
					}
					var headerRows: int = table.headerRows;
					var footerRows: int = table.footerRows;

					if ( footerRows > headerRows )
						footerRows = headerRows;
					var realHeaderRows: int = headerRows - footerRows;
					var headerHeight: Number = table.headerHeight;
					var footerHeight: Number = table.footerHeight;
					var skipHeader: Boolean = ( !firstPass && table.skipFirstHeader && listIdx <= headerRows );

					if ( !skipHeader )
					{
						yTemp -= headerHeight;

						if ( yTemp < minY || yTemp > maxY )
						{
							if ( firstPass )
							{
								compositeElements.shift();
								continue;
							}
							return NO_MORE_COLUMN;
						}
					}

					if ( listIdx < headerRows )
						listIdx = headerRows;

					if ( !table.complete )
						yTemp -= footerHeight;

					for ( k = listIdx; k < table.size; ++k )
					{
						rowHeight = table.getRowHeight( k );

						if ( yTemp - rowHeight < minY )
							break;
						yTemp -= rowHeight;
					}

					if ( !table.complete )
						yTemp += footerHeight;

					if ( k < table.size )
					{
						if ( table.splitRows && ( !table.splitLate || ( k == listIdx && firstPass ) ) )
						{
							if ( !splittedRow )
							{
								splittedRow = true;
								table = new PdfPTable( table );
								compositeElements[0] = table;
								var rows: Vector.<PdfPRow> = table.rows;

								for ( i = headerRows; i < listIdx; ++i )
									rows[i] = null;
							}
							var h: Number = yTemp - minY;
							var newRow: PdfPRow = table.getRow( k ).splitRow( table, k, h );

							if ( newRow == null )
							{
								if ( k == listIdx )
									return NO_MORE_COLUMN;
							} else
							{
								yTemp = minY;
								table.rows[++k] = newRow;
							}
						} else if ( !table.splitRows && k == listIdx && firstPass )
						{
							compositeElements.shift();
							splittedRow = false;
							continue;
						} else if ( k == listIdx && !firstPass && ( !table.splitRows || table.splitLate ) && ( table.footerRows == 0 || table.complete ) )
							return NO_MORE_COLUMN;
					}
					firstPass = false;

					if ( !simulate )
					{
						switch ( table.horizontalAlignment )
						{
							case Element.ALIGN_LEFT:
								break;
							case Element.ALIGN_RIGHT:
								x1 += rectangularWidth - tableWidth;
								break;
							default:
								x1 += ( rectangularWidth - tableWidth ) / 2;
						}
						var nt: PdfPTable = PdfPTable.shallowCopy( table );

						if ( !skipHeader && realHeaderRows > 0 )
						{
							nt.pdf_core::rows = nt.rows.concat( table.getRows( 0, realHeaderRows ) );
						} else
						{
							nt.headerRows = footerRows;
						}
						nt.pdf_core::rows = nt.rows.concat( table.getRows( listIdx, k ) );
						var showFooter: Boolean = !table.skipLastFooter;
						var newPageFollows: Boolean = false;

						if ( k < table.size )
						{
							nt.complete = true;
							showFooter = true;
							newPageFollows = true;
						}

						for ( var j: int = 0; j < footerRows && nt.complete && showFooter; ++j )
							nt.rows.push( table.getRow( j + realHeaderRows ) );
						rowHeight = 0;
						var index: int = nt.rows.length - 1;

						if ( showFooter )
							index -= footerRows;
						var last: PdfPRow = nt.rows[index];

						if ( table.isExtendLastRow( newPageFollows ) )
						{
							rowHeight = last.maxHeights;
							last.maxHeights = yTemp - minY + rowHeight;
							yTemp = minY;
						}

						if ( canvases != null )
							nt.writeSelectedRows( 0, -1, x1, yLineWrite, canvases );
						else
							nt.writeSelectedRows2( 0, -1, x1, yLineWrite, canvas );

						if ( table.isExtendLastRow( newPageFollows ) )
						{
							last.maxHeights = rowHeight;
						}
					} else if ( table.extendLastRow && minY > PdfPRow.BOTTOM_LIMIT )
					{
						yTemp = minY;
					}
					_yLine = yTemp;

					if ( !( skipHeader || table.complete ) )
						_yLine += footerHeight;

					if ( k >= table.size )
					{
						_yLine -= table.spacingAfter;
						compositeElements.shift();
						splittedRow = false;
						listIdx = 0;
					} else
					{
						if ( splittedRow )
						{
							var tempRows: Vector.<PdfPRow> = table.rows;

							for ( i = listIdx; i < k; ++i )
								tempRows[i] = null;
						}
						listIdx = k;
						return NO_MORE_COLUMN;
					}
				} else if ( element.type == Element.YMARK )
				{
					throw new NonImplementatioError( "Element.YMARK not yet implemented" );
					compositeElements.shift();
				} else
				{
					compositeElements.shift();
				}
			}
			return -1;
		}

		protected function setSimpleVars( org: ColumnText ): void
		{
			maxY = org.maxY;
			minY = org.minY;
			alignment = org.alignment;
			leftWall = null;

			if ( org.leftWall != null )
				leftWall = org.leftWall.concat();
			rightWall = null;

			if ( org.rightWall != null )
				rightWall = org.rightWall.concat();
			_yLine = org.yLine;
			currentLeading = org.currentLeading;
			fixedLeading = org.fixedLeading;
			_multipliedLeading = org.multipliedLeading;
			_canvas = org.canvas;
			_canvases = org.canvases;
			lineStatus = org.lineStatus;
			indent = org.indent;
			followingIndent = org.followingIndent;
			rightIndent = org.rightIndent;
			extraParagraphSpace = org.extraParagraphSpace;
			rectangularWidth = org.rectangularWidth;
			rectangularMode = org.rectangularMode;
			_spaceCharRatio = org.spaceCharRatio;
			lastWasNewline = org.lastWasNewline;
			linesWritten = org.linesWritten;
			_arabicOptions = org._arabicOptions;
			_runDirection = org._runDirection;
			_descender = org.descender;
			composite = org.composite;
			splittedRow = org.splittedRow;

			if ( org.composite )
			{
				compositeElements = org.compositeElements.concat();

				if ( splittedRow )
				{
					var table: PdfPTable = compositeElements[0] as PdfPTable;
					compositeElements[0] = new PdfPTable( table );
				}

				if ( org.compositeColumn != null )
					compositeColumn = duplicate( org.compositeColumn );
			}
			
			listIdx = org.listIdx;
			firstLineY = org.firstLineY;
			leftX = org.leftX;
			rightX = org.rightX;
			firstLineYDone = org.firstLineYDone;
			waitPhrase = org.waitPhrase;
			_useAscender = org._useAscender;
			_filledWidth = org._filledWidth;
			adjustFirstLine = org.adjustFirstLine;
		}

		private function addWaitingPhrase(): void
		{
			if ( bidiLine == null && waitPhrase != null )
			{
				bidiLine = new BidiLine();
				var chunks: Vector.<Object> = waitPhrase.getChunks();

				for ( var k: int = 0; k < chunks.length; ++k )
					bidiLine.addChunk( PdfChunk.fromChunk( Chunk( chunks[k] ), null ) );
				waitPhrase = null;
			}
		}

		static public function duplicate( src: ColumnText ): ColumnText
		{
			var ct: ColumnText = new ColumnText( null );
			ct.setACopy( src );
			return ct;
		}

		/**
		 * Shows a line of text. Only the first line is written.
		 *
		 * @param canvas where the text is to be written to
		 * @param alignment the alignment
		 * @param phrase the <CODE>Phrase</CODE> with the text
		 * @param x the x reference position
		 * @param y the y reference position
		 * @param rotation the rotation to be applied in degrees counterclockwise
		 */
		static public function showTextAligned( canvas: PdfContentByte, alignment: int, phrase: Phrase, x: Number, y: Number,
						rotation: Number, runDirection: int = 0, arabicOptions: int = 0 ): void
		{
			if ( alignment != Element.ALIGN_LEFT && alignment != Element.ALIGN_CENTER && alignment != Element.ALIGN_RIGHT )
				alignment = Element.ALIGN_LEFT;
			canvas.saveState();
			var ct: ColumnText = new ColumnText( canvas );
			var lly: Number = -1;
			var ury: Number = 2;
			var llx: Number;
			var urx: Number;

			switch ( alignment )
			{
				case Element.ALIGN_LEFT:
					llx = 0;
					urx = 20000;
					break;
				case Element.ALIGN_RIGHT:
					llx = -20000;
					urx = 0;
					break;
				default:
					llx = -20000;
					urx = 20000;
					break;
			}

			if ( rotation == 0 )
			{
				llx += x;
				lly += y;
				urx += x;
				ury += y;
			} else
			{
				var alpha: Number = rotation * Math.PI / 180.0;
				var cos: Number = Math.cos( alpha );
				var sin: Number = Math.sin( alpha );
				canvas.concatCTM( cos, sin, -sin, cos, x, y );
			}
			ct.addText( phrase );
			ct.setLeading( 2 );
			ct._alignment = alignment;
			ct.setSimpleColumn( llx, lly, urx, ury );

			if ( runDirection == PdfWriter.RUN_DIRECTION_RTL )
			{
				if ( alignment == Element.ALIGN_LEFT )
					alignment = Element.ALIGN_RIGHT;
				else if ( alignment == Element.ALIGN_RIGHT )
					alignment = Element.ALIGN_LEFT;
			}
			ct.alignment = alignment;
			ct.runDirection = runDirection;

			try
			{
				ct.go();
			} catch ( e: DocumentError )
			{
				throw new ConversionError( e );
			}
			canvas.restoreState();
		}
	}
}