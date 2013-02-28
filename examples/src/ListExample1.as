package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.List;
	import org.purepdf.elements.ListItem;
	import org.purepdf.elements.Phrase;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class ListExample1 extends DefaultBasicExample
	{
		public function ListExample1( d_list: Array=null )
		{
			super(["Ordered list example"]);
			registerDefaultFont();
		}

		override protected function execute( event: Event=null ): void
		{
			super.execute();

			createDocument( "List example" );
			document.open();

			var phrase: Phrase = new Phrase( "Quick brown fox jumps over", null );
			document.add( phrase );

			var list1: List = new List( List.ORDERED, 20 );
			list1.add( new ListItem( "the lazy dog" ) );
			list1.add( new ListItem( "the lazy cat" ) );
			list1.add( new ListItem( "the fence" ) );
			document.add( list1 );

			document.add( Chunk.NEWLINE );
			document.add( phrase );

			var list2: List = new List( List.UNORDERED, 10 );
			list2.add( "the lazy dog" );
			list2.add( "the lazy cat" );
			list2.add( "the fence" );
			document.add( list2 );

			document.add( Chunk.NEWLINE );
			document.add( phrase );

			var list3: List = new List( List.ORDERED, 20 );
			list3.lettered = List.ALPHABETICAL;
			list3.add( new ListItem( "the lazy dog" ) );
			list3.add( new ListItem( "the lazy cat" ) );
			list3.add( new ListItem( "the fence" ) );
			document.add( list3 );

			document.add( Chunk.NEWLINE );
			document.add( phrase );

			var list4: List = new List( List.UNORDERED, 30 );
			list4.symbol = new Chunk("----->");
			list4.indentationLeft = 10;
			list4.add( "the lazy dog" );
			list4.add( "the lazy cat" );
			list4.add( "the fence" );
			document.add( list4 );

			document.add( Chunk.NEWLINE );
			document.add( phrase );

			var list5: List = new List( List.ORDERED, 20 );
			list5.first = 11;
			list5.add( new ListItem( "the lazy dog" ) );
			list5.add( new ListItem( "the lazy cat" ) );
			list5.add( new ListItem( "the fence" ) );
			document.add( list5 );

			document.add( Chunk.NEWLINE );

			var list: List = new List( List.UNORDERED, 10 );
			list.symbol = new Chunk( '*' );
			list.add( "Quick brown fox jumps over" );
			list.add( list1 );
			list.add( "Quick brown fox jumps over" );
			list.add( list3 );
			list.add( "Quick brown fox jumps over" );
			list.add( list5 );
			document.add( list );

			document.close();
			save();
		}
	}
}