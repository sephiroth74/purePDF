package
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.MultiColumnText;
	import org.purepdf.elements.Phrase;
	import org.purepdf.io.LineReader;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;

	public class MultiColumnIrregular extends DefaultBasicExample
	{
		[Embed(source="assets/caesar.txt", mimeType="application/octet-stream")]
		private var cls1: Class;
		
		private var lines: Vector.<String>;
		
		public function MultiColumnIrregular(d_list:Array=null)
		{
			super(["Creates a multcolumn text which wraps","text around a diamond shape"]);
			var buffer: ByteArray = new cls1();
			var reader: LineReader = new LineReader( buffer );
			var line: String;
			
			registerDefaultFont();
			lines = new Vector.<String>();
			
			while ((line = reader.readLine()) != null) {
				lines.push( line );
			}
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			var baseFont: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false, true );
			var font: Font = new Font( Font.UNDEFINED, 10, Font.UNDEFINED, null, baseFont );
			
			
			var mct: MultiColumnText = new MultiColumnText();
			mct.desiredHeight = document.top() - document.bottom();
			mct.alignment = Element.ALIGN_JUSTIFIED;
			
			var diamondHeight: Number = 400;
			var diamondWidth: Number = 400;
			var gutter: Number = 10;
			var bodyHeight: Number = document.top() - document.bottom();
			var colMaxWidth: Number = (document.right() - document.left() - (gutter * 2)) / 2;
			var diamondTop: Number = document.top()	- ((bodyHeight - diamondHeight) / 2);
			var diamondInset: Number = colMaxWidth - (diamondWidth / 2);
			var centerX: Number = (document.right() - document.left()) / 2 + document.left();
			
			var left: Vector.<Number> = Vector.<Number>([ document.left(), document.top(), document.left(), document.bottom() ]);
			var right: Vector.<Number> = Vector.<Number>([ document.left() + colMaxWidth, document.top(), document.left() + colMaxWidth, diamondTop,	document.left() + diamondInset,
				diamondTop - diamondHeight / 2,
				document.left() + colMaxWidth, diamondTop - diamondHeight,
				document.left() + colMaxWidth, document.bottom() ]);
			
			mct.addColumn(left, right);
			
			
			left = Vector.<Number>([ document.right() - colMaxWidth,
				document.top(), document.right() - colMaxWidth, diamondTop,
				document.right() - diamondInset,
				diamondTop - diamondHeight / 2,
				document.right() - colMaxWidth, diamondTop - diamondHeight,
				document.right() - colMaxWidth, document.bottom() ]);
			
			right = Vector.<Number>([ document.right(), document.top(),
				document.right(), document.bottom() ]);
			mct.addColumn(left, right);
			
			var line: String;
			while((line = lines.pop())) {
				mct.addElement( new Phrase(line + "\n", font ));
			}
			
			var cb: PdfContentByte = document.getDirectContent();
			do 
			{
				cb.saveState();
				cb.setLineWidth(5);
				cb.setColorStroke(RGBColor.GRAY);
				cb.moveTo(centerX, document.top());
				cb.lineTo(centerX, document.bottom());
				cb.stroke();
				cb.moveTo(centerX, diamondTop);
				cb.lineTo(centerX - (diamondWidth / 2), diamondTop - (diamondHeight / 2));
				cb.lineTo(centerX, diamondTop - diamondHeight);
				cb.lineTo(centerX + (diamondWidth / 2), diamondTop - (diamondHeight / 2));
				cb.lineTo(centerX, diamondTop);
				cb.setColorFill(RGBColor.GRAY);
				cb.fill();
				cb.restoreState();
				document.add(mct);
				mct.nextColumn();
			} while( mct.overflow );
			
			document.close();
			save();
		}
	}
}