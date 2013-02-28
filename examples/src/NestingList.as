package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.List;
	import org.purepdf.elements.ListItem;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class NestingList extends DefaultBasicExample
	{
		[Embed(source="assets/fonts/AshleyScriptMTStd.otf", mimeType="application/octet-stream")] private var cls1: Class;
		
		public function NestingList()
		{
			super( [ "Create nested lists" ] );
			
			FontsResourceFactory.getInstance().registerFont("AshleyScriptMTStd.otf", new cls1() );
		}

		override protected function execute( event: Event = null ): void
		{
			super.execute();
			createDocument();
			document.open();
			
			var bf: BaseFont = BaseFont.createFont("AshleyScriptMTStd.otf", BaseFont.WINANSI, BaseFont.EMBEDDED );
			var font: Font = new Font( -1, 20, -1, null, bf );

			var list1: List = new List( List.ORDERED, 20 );
			list1.symbol = new Chunk("-", font );
			list1.add( ListItem.fromChunk( new Chunk( "Level 1 - Item 1", font ) ) );
			list1.add( ListItem.fromChunk( new Chunk( "Level 1 - Item 2", font ) ) );
			list1.add( ListItem.fromChunk( new Chunk( "Level 1 - Item 3", font ) ) );

			var list2: List = new List( List.ORDERED, 20 );
			list2.symbol = new Chunk("-", font );
			list2.add( ListItem.fromChunk( new Chunk( "Level 2 - Item 1", font ) ) );
			list2.add( ListItem.fromChunk( new Chunk( "Level 2 - Item 2", font ) ) );

			var list3: List = new List( List.ORDERED, 20 );
			list3.symbol = new Chunk("-", font );
			list3.add( ListItem.fromChunk( new Chunk( "Level 3 - Item 1", font ) ) );
			list3.add( ListItem.fromChunk( new Chunk( "Level 3 - Item 2", font ) ) );
			list3.add( ListItem.fromChunk( new Chunk( "Level 3 - Item 3", font ) ) );
			list3.add( ListItem.fromChunk( new Chunk( "Level 3 - Item 4", font ) ) );
			list2.add( list3 );

			list1.add( list2 );
			list1.add( ListItem.fromChunk( new Chunk( "Level 1 - Item 4", font ) ) );

			document.add( list1 );

			document.close();
			save();

		}
	}
}