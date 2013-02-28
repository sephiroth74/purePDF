package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.GreekList;
	import org.purepdf.elements.ListItem;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.RomanList;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class ListExample2 extends DefaultBasicExample
	{
		public function ListExample2(d_list:Array=null)
		{
			super(["Create ordered list using roman, greek","and zapfdingbats list bullet styles"]);

			registerDefaultFont();
			FontsResourceFactory.getInstance().registerFont( BaseFont.SYMBOL, new BuiltinFonts.SYMBOL() );
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			
			createDocument();
			document.open();
			
			var phrase: Phrase = new Phrase("Here's a new list", null );
			document.add( phrase );
			
			var romanlist: RomanList;
			romanlist = new RomanList( 20 );
			romanlist.lowercase = true;
			romanlist.add(new ListItem("first line"));
			romanlist.add(new ListItem("second line"));
			romanlist.add(new ListItem("third line"));
			romanlist.add(new ListItem("fourth line"));
			romanlist.add(new ListItem("fifth line"));
			document.add(romanlist);
			document.add(Chunk.NEWLINE);
			document.add(phrase);
			
			romanlist = new RomanList( 20 );
			romanlist.lowercase = false;
			romanlist.add(new ListItem("first line"));
			romanlist.add(new ListItem("second line"));
			romanlist.add(new ListItem("third line"));
			romanlist.add(new ListItem("fourth line"));
			romanlist.add(new ListItem("fifth line"));			
			document.add(romanlist);
			document.add(Chunk.NEWLINE);
			document.add(phrase);
			
			
			var greeklist: GreekList;
			greeklist = new GreekList(20);
			greeklist.lowercase = true;
			greeklist.add(new ListItem("first line"));
			greeklist.add(new ListItem("second line"));
			greeklist.add(new ListItem("third line"));
			greeklist.add(new ListItem("fourth line"));
			greeklist.add(new ListItem("fifth line"));
			document.add(greeklist);
			document.add(Chunk.NEWLINE);
			
			document.add(phrase);
			greeklist = new GreekList(20);
			greeklist.lowercase = false;
			greeklist.add(new ListItem("first line"));
			greeklist.add(new ListItem("second line"));
			greeklist.add(new ListItem("third line"));
			greeklist.add(new ListItem("fourth line"));
			greeklist.add(new ListItem("fifth line"));
			document.add(greeklist);
			
			/*
			document.addElement(Chunk.NEWLINE);
			document.addElement(phrase);
			var zapfdingbatslist: ZapfDingbatsList;
			zapfdingbatslist = new ZapfDingbatsList(42, 15);
			zapfdingbatslist.add(new ListItem("the lazy dog"));
			zapfdingbatslist.add(new ListItem("the lazy cat"));
			document.addElement(zapfdingbatslist);
			document.addElement(Chunk.NEWLINE);
			document.addElement(phrase);
			
			var zapfdingbatsnumberlist: ZapfDingbatsNumberList;
			zapfdingbatsnumberlist = new ZapfDingbatsNumberList(0, 15);
			zapfdingbatsnumberlist.add(new ListItem("the lazy dog"));
			zapfdingbatsnumberlist.add(new ListItem("the lazy cat"));
			document.addElement(zapfdingbatsnumberlist);
			document.addElement(Chunk.NEWLINE);
			document.addElement(phrase);
			zapfdingbatsnumberlist = new ZapfDingbatsNumberList(1, 15);
			zapfdingbatsnumberlist.add(new ListItem("the lazy dog"));
			zapfdingbatsnumberlist.add(new ListItem("the lazy cat"));
			document.addElement(zapfdingbatsnumberlist);
			document.addElement(Chunk.NEWLINE);
			document.addElement(phrase);
			zapfdingbatsnumberlist = new ZapfDingbatsNumberList(2, 15);
			zapfdingbatsnumberlist.add(new ListItem("the lazy dog"));
			zapfdingbatsnumberlist.add(new ListItem("the lazy cat"));
			document.addElement(zapfdingbatsnumberlist);
			document.addElement(Chunk.NEWLINE);
			document.addElement(phrase);
			zapfdingbatsnumberlist = new ZapfDingbatsNumberList(3, 15);
			zapfdingbatsnumberlist.add(new ListItem("the lazy dog"));
			zapfdingbatsnumberlist.add(new ListItem("the lazy cat"));
			document.addElement(zapfdingbatsnumberlist);
			*/
			document.close();
			save();
		}
	}
}