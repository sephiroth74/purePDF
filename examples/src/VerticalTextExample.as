package
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Phrase;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.VerticalText;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.cmaps.CJKFontResourceFactory;
	import org.purepdf.pdf.fonts.cmaps.CMapResourceFactory;
	import org.purepdf.resources.BuiltinCJKFonts;
	import org.purepdf.resources.CMap;
	import org.purepdf.resources.ICMap;
	import org.purepdf.utils.ByteArrayUtils;
	import org.purepdf.utils.IProperties;
	import org.purepdf.utils.Properties;
	import org.purepdf.utils.StringUtils;

	public class VerticalTextExample extends DefaultBasicExample
	{
		protected var text_1: String = "\u4e03\u4eba\u306e\u4f8d";
		protected var text_2: String = "\u65e6\u672c\u6c34";
		protected var text_3: String = "You embarrass me. You're overestimating me. Listen, I'm not a man with any special skill, but I've had plenty of experience in battles; losing battles, all of them.";
		
		public function VerticalTextExample()
		{
			super(["write some latin and japanese (i think!) vertical text"]);
			registerDefaultFont();
			
			var map1: ICMap = new CMap( new CMap.UniJIS_UCS2_V() );
			var map2: ICMap = new CMap( new CMap.UniJIS_UCS2_H() );
			var map3: ICMap = new CMap( new CMap.Adobe_Japan1_UCS2() );
			CMapResourceFactory.getInstance().registerCMap( BaseFont.UniJIS_UCS2_V, map1 );
			CMapResourceFactory.getInstance().registerCMap( BaseFont.UniJIS_UCS2_H, map2 );
			CMapResourceFactory.getInstance().registerCMap( BaseFont.AdobeJapan1_UCS2, map3 );
			
			// load and register a property
			var prop: IProperties = new Properties();
			prop.load( new BuiltinCJKFonts.KozMinPro_Regular() );
			CJKFontResourceFactory.getInstance().registerProperty( BuiltinCJKFonts.getFontName( BuiltinCJKFonts.KozMinPro_Regular ), prop );
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			
			PdfDocument.compress = false;
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			var bf: BaseFont;
			var font: Font;
			var vt: VerticalText;
			
			bf = BaseFont.createFont("KozMinPro-Regular", BaseFont.UniJIS_UCS2_V, BaseFont.NOT_EMBEDDED );
			font = new Font( -1, 20, -1, null, bf );
			vt = new VerticalText( cb );
			vt.setVerticalLayout(PageSize.A4.width * 0.75, PageSize.A4.height - 36, PageSize.A4.height - 72, 8, 30);
			vt.addChunk(new Chunk(text_1, font));
			vt.go();
			vt.addPhrase( new Phrase( text_2, font));
			vt.go();
			
			
			bf = BaseFont.createFont("KozMinPro-Regular", "Identity-V", BaseFont.NOT_EMBEDDED);
			font = new Font( -1, 20, -1, null, bf);
			vt = new VerticalText(cb);
			vt.setVerticalLayout(PageSize.A4.width * 0.25, PageSize.A4.height - 36, PageSize.A4.height - 72, 8, 30);
			vt.addPhrase( new Phrase(convertCIDs(text_3), font));
			vt.go();
			
			document.close();
			save();
		}
		
		public static function convertCIDs(text: String ): String
		{
			var cid: Vector.<int> = StringUtils.toCharArray(text);
			for (var k: int = 0; k < cid.length; ++k) 
			{
				var c: int = cid[k];
				if (c == '\n'.charCodeAt(0))
					cid[k] = '\uff00'.charCodeAt(0);
				else
					cid[k] = (c - 32 + 8720);
			}
			
			var s: String = "";
			for( k = 0; k < cid.length; ++k )
			{
				s += String.fromCharCode( cid[k] );
			}
			return s;
			
			
		}
	}
}