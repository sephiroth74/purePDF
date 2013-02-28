package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.cmaps.CJKFontResourceFactory;
	import org.purepdf.pdf.fonts.cmaps.CMapResourceFactory;
	import org.purepdf.resources.BuiltinCJKFonts;
	import org.purepdf.resources.CMap;
	import org.purepdf.resources.ICMap;
	import org.purepdf.utils.IProperties;
	import org.purepdf.utils.Properties;

	public class ChineseKoreanJapanese extends DefaultBasicExample
	{
		public function ChineseKoreanJapanese()
		{
			super(["This example will show how to load cmaps and properties","in order to write some CJK chars"]);
			
			// load and register a cmap
			var map: ICMap = new CMap( new CMap.UniGB_UCS2_H() );
			CMapResourceFactory.getInstance().registerCMap( BaseFont.UniGB_UCS2_H, map );
			
			// load and register a property
			var prop: IProperties = new Properties();
			prop.load( new BuiltinCJKFonts.STSong_Light() );
			
			CJKFontResourceFactory.getInstance().registerProperty( BuiltinCJKFonts.getFontName( BuiltinCJKFonts.STSong_Light ), prop );
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			createDocument();
			document.open();
			
			var bf: BaseFont = BaseFont.createFont( BuiltinCJKFonts.getFontName( BuiltinCJKFonts.STSong_Light ), 
					BaseFont.UniGB_UCS2_H, BaseFont.NOT_EMBEDDED, true );
			
			var font: Font = new Font( -1. -1, 32, -1, null, bf );
			
			document.add( new Paragraph("\u5341\u950a\u57cb\u4f0f", font));
			
			document.close();
			save();
		}
	}
}