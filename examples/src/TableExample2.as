package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	
	import org.purepdf.Font;
	import org.purepdf.colors.CMYKColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.SimpleCell;
	import org.purepdf.elements.SimpleTable;
	import org.purepdf.factories.FontFactory;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPRow;
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.PdfPage;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class TableExample2 extends DefaultBasicExample
	{
		public static const COLUMNWIDTHS: Vector.<Number> = Vector.<Number>( [5, 7, 35, 4, 4, 10, 15, 4, 4, 4, 4, 4] );
		public static const NUMCOLUMNS: int = 12;
		public const BEFORE: int = 0;
		public const BOLDNUMBER: int = 7;
		public const COURSE: int = 3;
		public const EMPTY: int = 0;
		public const GROUP: int = 1;
		public const GROUPTITLE: int = 3;
		public const HEADER: int = 5;
		public const NUMBER: int = 6;
		public const OPTION: int = 2;
		public const STRING: int = 8;
		public const TITLE: int = 1;
		public const UNIT: int = 2;
		public const UNITTITLE: int = 4;
		protected var buffers: String;
		protected var count: Boolean = false;
		protected var currentRow: SimpleCell;
		protected var status: int = BEFORE;
		protected var table: SimpleTable;
		protected var totalD: int = 0;
		protected var totalE: int = 0;
		protected var unit: Boolean = false;
		protected var units: int = 0;
		
		[Embed( source="assets/studyprogram.xml", mimeType="application/octet-stream" )]
		private var cls: Class;
		
		private var font11: Font;
		private var font14: Font;
		private var font11b: Font;
		private var font12: Font;
		private var font12b: Font;
		private var xml: XML;

		public function TableExample2( d_list: Array = null )
		{
			super( ["Create a more advanced table parsing an xml for","rows and columns.","It will also automatically split the table accross pages."] );
			
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA, new BuiltinFonts.HELVETICA() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new BuiltinFonts.HELVETICA_BOLD() );
			
			font11	= FontFactory.getFont( BaseFont.HELVETICA_BOLD, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED, 11 );
			font14	= FontFactory.getFont( BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED, 14, -1, new CMYKColor(0.9, 0.7, 0.4, 0.1) );
			font12	= FontFactory.getFont( BaseFont.HELVETICA_BOLD, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED, 12 );
			font12b = FontFactory.getFont( BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED, 12 );
			font11b = FontFactory.getFont( BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED, 11 );
			
			table = new SimpleTable();
			table.widthPercentage = 100;
			
			currentRow = new SimpleCell( SimpleCell.ROW );
			var b: ByteArray = new cls() as ByteArray;
			b.position = 0;
			xml = new XML( b.readUTFBytes( b.length ) );
		}

		public function characters( content: String ): void
		{
			buffers += content + " ";
		}

		public function endElement( element: XML ): void
		{
			var qName: String = element.name().toString().toLowerCase();
			var d: String;
			var e: String;

			try
			{
				if ( "studyprogram" == qName )
				{
					addFooter();
					return;
				}

				switch ( status )
				{
					case BEFORE:
						if ( "faculty" == qName || "program" == qName )
						{
							currentRow.add( getCell( buffers, TITLE ) );
							table.add( currentRow );
							currentRow = new SimpleCell( SimpleCell.ROW );
						} else if ( "option" == qName )
						{
							currentRow.add( getCell( "Option: " + buffers, OPTION ) );
							table.add( currentRow );
							currentRow = new SimpleCell( SimpleCell.ROW );
						}
						break;
					case GROUP:
						if ( "title" == qName )
						{
							currentRow.add( getCell( "", EMPTY ) );
							currentRow.add( getCell( buffers, GROUPTITLE ) );
							table.add( currentRow );
							currentRow = new SimpleCell( SimpleCell.ROW );
							break;
						}
						break;
					case UNIT:
						if ( "title" == qName )
						{
							currentRow.add( getCell( buffers, UNITTITLE ) );
							break;
						}
						if ( "d" == qName )
						{
							d = buffers;

							if ( count )
							{
								totalD += parseInt( d );
								currentRow.add( getCell( d, BOLDNUMBER ) );
							} else
							{
								currentRow.add( getCell( d, NUMBER ) );
							}
							break;
						}
						if ( "e" == qName )
						{
							e = buffers;

							if ( count )
							{
								totalE += parseInt( e );
								currentRow.add( getCell( e, BOLDNUMBER ) );
							} else
							{
								currentRow.add( getCell( e, NUMBER ) );
							}
							table.add( currentRow );
							currentRow = new SimpleCell( SimpleCell.ROW );
							unit = false;
							break;
						}
						break;
					case COURSE:
						if ( "coursenumber" == qName )
						{
							if ( unit )
							{
								unit = false;
							} else
							{
								currentRow.add( getCell( "", EMPTY ) );
							}
							currentRow.add( getCell( buffers, NUMBER ) );
							break;
						}
						if ( "title" == qName || "teacher" == qName )
						{
							currentRow.add( getCell( buffers, STRING ) );
							break;
						}
						if ( "semester" == qName || "pt" == qName || "department" == qName || "a" == qName || "b" == qName || "c" ==
										qName )
						{
							currentRow.add( getCell( buffers, NUMBER ) );
							break;
						}
						if ( "d" == qName )
						{
							d = buffers;

							if ( count )
							{
								totalD += parseInt( d );
								currentRow.add( getCell( d, BOLDNUMBER ) );
							} else
							{
								currentRow.add( getCell( d, NUMBER ) );
							}
							break;
						}
						if ( "e" == qName )
						{
							e = buffers;

							if ( count )
							{
								totalE += parseInt( e );
								currentRow.add( getCell( e, BOLDNUMBER ) );
							} else
							{
								currentRow.add( getCell( e, NUMBER ) );
							}
							table.add( currentRow );
							currentRow = new SimpleCell( SimpleCell.ROW );
							break;
						}
						break;
				}
				buffers = "";
			} catch ( e: Error )
			{
				trace( e.getStackTrace() );
			}
		}

		override protected function execute( event: Event = null ): void
		{
			super.execute();
			createDocument("Table Example 2", PageSize.A4.rotate() );
			document.open();
			
			var p: Paragraph = new Paragraph( "Academic Year 2009/2010\n\n" );
			p.alignment = Element.ALIGN_CENTER;
			document.add( p );
			
			if( this.parent )
				addEventListener("parseComplete", onXMLParseComplete );
			
			parse( xml );
			
			if( this.parent == null )
			{
				document.add( table );
				var p: Paragraph = new Paragraph( "Sem.: 1 = first semester, 2 = second semester, Y = annual course");
				p.alignment = Element.ALIGN_RIGHT;
				document.add( p );
				p = new Paragraph("P-T = courses can be taken on a part-time basis, 1 = first part, 2 = second part");
				p.alignment = Element.ALIGN_RIGHT;
				document.add(p);
				
				document.close();
				save();
			}
		}
		
		private function onXMLParseComplete( event: Event ): void
		{
			document.add( table );
			
			end_time = new Date().getTime();
			
			addResultTime( end_time - start_time );
			
			var btn: Sprite = createButton( 0xFFFF00, "save", onPostSave );
			center( btn, create_button );
			create_button.parent.addChild( btn );
			
			var p: Paragraph = new Paragraph( "Sem.: 1 = first semester, 2 = second semester, Y = annual course");
			p.alignment = Element.ALIGN_RIGHT;
			document.add( p );
			p = new Paragraph("P-T = courses can be taken on a part-time basis, 1 = first part, 2 = second part");
			p.alignment = Element.ALIGN_RIGHT;
			document.add(p);
		}
		
		private function onPostSave( event: MouseEvent ): void
		{
			start_time = new Date().getTime();
			document.close();
			save();
		}

		private function addFooter(): void
		{
			var headerRow: SimpleCell = new SimpleCell( SimpleCell.ROW );
			headerRow.add( getCell( "", EMPTY ) );
			headerRow.add( getCell( "", UNITTITLE ) );
			headerRow.add( getCell( totalD.toString(), BOLDNUMBER ) );
			headerRow.add( getCell( totalE.toString(), BOLDNUMBER ) );
			table.add( headerRow );
		}

		private function addHeader(): void
		{
			var headerRow: SimpleCell = new SimpleCell( SimpleCell.ROW );
			headerRow.add( getCells( "Unit", HEADER, 4 ) );
			headerRow.add( getCells( "Code", HEADER, 6 ) );
			headerRow.add( getCells( "Course", HEADER, 38 ) );
			headerRow.add( getCells( "Sem.", HEADER, 5 ) );
			headerRow.add( getCells( "P-T", HEADER, 5 ) );
			headerRow.add( getCells( "Dept.", HEADER, 7 ) );
			headerRow.add( getCells( "Lecturer in Charge", HEADER, 15 ) );
			headerRow.add( getCells( "A", HEADER, 4 ) );
			headerRow.add( getCells( "B", HEADER, 4 ) );
			headerRow.add( getCells( "C", HEADER, 4 ) );
			headerRow.add( getCells( "D", HEADER, 4 ) );
			headerRow.add( getCells( "E", HEADER, 4 ) );
			table.add( headerRow );
		}

		private function getCell( s: String, style: int ): SimpleCell
		{
			switch ( style )
			{
				case HEADER:
					throw new Error( "You can't use this method if you want to get a HeaderCell." );
				default:
					return getCells( s, style, -1 );
			}
		}

		private function getCells( s: String, style: int, width: Number ): SimpleCell
		{
			var cell: SimpleCell = new SimpleCell( SimpleCell.CELL );
			var p: Paragraph;

			switch ( style )
			{
				case EMPTY:
					cell.border = ( RectangleElement.BOX );
					break;
				case TITLE:
					p = new Paragraph( s, font14 );
					p.alignment = ( Element.ALIGN_CENTER );
					cell.add( p );
					cell.colspan = ( NUMCOLUMNS );
					cell.border = ( RectangleElement.NO_BORDER );
					break;
				case OPTION:
					p = new Paragraph( s, font12 );
					p.alignment = ( Element.ALIGN_CENTER );
					cell.add( p );
					cell.colspan = ( NUMCOLUMNS );
					cell.border = ( RectangleElement.NO_BORDER );
					break;
				case GROUPTITLE:
					p = new Paragraph( s, font12b );
					p.alignment = ( Element.ALIGN_LEFT );
					cell.add( p );
					cell.colspan = ( NUMCOLUMNS - 1 );
					cell.paddingLeft = ( 5 );
					cell.border = ( RectangleElement.BOX );
					break;
				case UNITTITLE:
					p = new Paragraph( s, font12b );
					p.alignment = ( Element.ALIGN_LEFT );
					cell.add( p );
					cell.colspan = ( NUMCOLUMNS - 3 );
					cell.border = ( RectangleElement.BOX );
					cell.paddingLeft = ( 5 );
					break;
				case HEADER:
					p = new Paragraph( s, font11 );
					p.alignment = ( Element.ALIGN_CENTER );
					cell.add( p );
					cell.widthpercentage = ( width );
					cell.border = ( RectangleElement.BOX );
					break;
				case NUMBER:
					p = new Paragraph( s, font11b );
					p.alignment = ( Element.ALIGN_CENTER );
					cell.add( p );
					cell.border = ( RectangleElement.BOX );
					break;
				case BOLDNUMBER:
					p = new Paragraph( s, font11 );
					p.alignment = ( Element.ALIGN_CENTER );
					cell.add( p );
					cell.border = ( RectangleElement.BOX );
					break;
				case STRING:
					p = new Paragraph( s, font11b );
					p.alignment = ( Element.ALIGN_LEFT );
					cell.add( p );
					cell.border = ( RectangleElement.BOX );
					cell.paddingLeft = ( 5 );
					break;
			}
			cell.borderWidth = 0.3;
			cell.paddingBottom = ( 5 );
			return cell;
		}

		private function parse( x: XML ): void
		{
			var children: XMLList = x.children();

			for ( var a: int = 0; a < children.length(); ++a )
			{
				startElement( children[a] );
				endElement( children[a] );
			}
			
			dispatchEvent( new Event("parseComplete") );
		}

		private function startElement( element: XML ): void
		{
			var qName: String = element.name().toString().toLowerCase();
			var p: Paragraph;

			try
			{
				if ( "group" == qName )
				{
					if ( status == BEFORE )
					{
						addHeader();
					}
					status = GROUP;
				} else if ( "unit" == qName )
				{
					status = UNIT;
					units++;
					currentRow.add( getCell( units.toString(), NUMBER ) );
					unit = true;
				} else if ( "course" == qName )
				{
					status = COURSE;
				} else if ( "d" == qName || "e" == qName )
				{
					count = "true" == ( element.attribute( "count" ).valueOf() );
				}
				buffers = "";
			} catch ( e: Error )
			{
				trace( e.getStackTrace() );
			}
			var text: String = element.text();
			characters( text );
			var children: XMLList = element.children();

			for ( var a: int = 0; a < children.length(); ++a )
			{
				if ( XML( children[a] ).name() )
				{
					startElement( children[a] );
					endElement( children[a] );
				}
			}
		}
	}
}