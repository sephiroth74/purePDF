package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.cmaps.CJKFontResourceFactory;
	import org.purepdf.pdf.fonts.cmaps.CMapResourceFactory;
	import org.purepdf.resources.BuiltinCJKFonts;
	import org.purepdf.resources.CMap;
	import org.purepdf.resources.ICMap;
	import org.purepdf.utils.IProperties;
	import org.purepdf.utils.Properties;
	
	public class KoreanNotEmbed extends DefaultBasicExample
	{
		private static var font_class: Class = BuiltinCJKFonts.HYGoThic_Medium;
		private static var encoding: String = BaseFont.UniKS_UCS2_H;
		
		public function KoreanNotEmbed()
		{
			super(["This example will show how to load cmaps and properties","in order to write some Korean chars"]);
			
			// load and register a cmap
			var map: ICMap = new CMap( new CMap.UniKS_UCS2_H() );
			CMapResourceFactory.getInstance().registerCMap( encoding, map );
			
			// load and register a property
			var prop: IProperties = new Properties();
			prop.load( new font_class() );
			
			CJKFontResourceFactory.getInstance().registerProperty( BuiltinCJKFonts.getFontName( font_class ), prop );
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			createDocument();
			document.open();
			
			var bf: BaseFont = BaseFont.createFont( BuiltinCJKFonts.getFontName( font_class ), 
				encoding, BaseFont.NOT_EMBEDDED, true );
			
			var font1: Font = new Font( -1. -1, 48, -1, RGBColor.BLACK, bf );
			var font2: Font = new Font( -1. -1, 32, -1, RGBColor.DARK_GRAY, bf );
			var font3: Font = new Font( -1. -1, 24, -1, RGBColor.LIGHT_GRAY, bf );
			
			document.add( new Paragraph("\uAC11\uAC79\uB5A4\uD6D7", font1 ));
			document.add( new Paragraph("\uC6E0\uC610\uC5E1\uC399", font2 ));
			document.add( new Paragraph("\ub85c\uadf8\uc778", font3 ));
			
			document.close();
			save();
		}
	}
}