package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.IElement;
	import org.purepdf.elements.MultiColumnText;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.factories.FontFactory;
	import org.purepdf.pdf.fonts.BaseFont;

	public class MultiColumnPoem extends DefaultBasicExample
	{
		private var baseFont: BaseFont; 
		
		public function MultiColumnPoem(d_list:Array=null)
		{
			super(["Example usage of MultiColumnText"]);
			registerDefaultFont();
			
			baseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false, true );
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			var mct: MultiColumnText = new MultiColumnText();
			mct.addRegularColumns( document.left(), document.right(), 10, 3);
			
			var titleFont: Font = new Font( Font.HELVETICA, 12, -1, null, baseFont );
			
			for( var i: int = 0; i < 30; i++ ) 
			{
				mct.addElement( new Paragraph( (i + 1).toString(), titleFont ));
				mct.addElement( newParagraph(randomWord(noun), Element.ALIGN_CENTER, Font.BOLDITALIC));
				for ( var j: int = 0; j < 4; j++) 
				{
					mct.addElement(newParagraph(poemLine(), Element.ALIGN_LEFT,	Font.NORMAL));
				}
				mct.addElement( newParagraph(randomWord(adverb), Element.ALIGN_LEFT, Font.NORMAL));
				mct.addElement( newParagraph("\n\n", Element.ALIGN_LEFT, Font.NORMAL));
			}
			document.add(mct);
			
			document.close();
			save();
		}
		
		private function newParagraph( text: String, alignment: int, type: int ): IElement
		{
			var font: Font = new Font( Font.HELVETICA, 9, type, null, baseFont );
			var p: Paragraph = new Paragraph(text, font);
			p.alignment = alignment;
			p.leading = font.size * 1.2;
			return p;
		}
		
		private function randomWord( type: Vector.<String> ): String
		{
			return type[int(Math.random() * type.length)];
		}
		
		public function poemLine(): String
		{
			var results: String = "";
			results += randomWord(adjective);
			results += " ";
			results += randomWord(noun);
			results += " ";
			results += randomWord(verb);
			results += " ";
			results += randomWord(adverb);
			results += ", ";
			return results;
		}
		
		private const verb: Vector.<String> = Vector.<String>([
			"flows", "draws", "renders", "throws exception",
			"runs", "crashes", "downloads", "usurps", "vexes", "whispers",
			"boils", "capitulates", "crashes", "craves", "looks", "defies",
			"defers", "defines", "envelops", "entombs", "falls", "fails",
			"halts", "appears", "nags", "overflows", "burns", "dies", "writes",
			"flushes" ]);
		
		private const noun: Vector.<String> = Vector.<String>([
			"ColumnText", "paragraph", "phrase", "chunk",
			"PdfContentByte", "PdfPTable", "iText", "color",
			"vertical alignment", "horizontal alignment", "PdfWriter",
			"ListItem", "PdfStamper", "PDF", "HTML", "XML", "column", "font",
			"table", "FDF", "field", "NullPointerException", "CJK font" ]);
		
		private const adjective: Vector.<String> = Vector.<String>([
			"foul", "broken", "gray", "slow",
			"beautiful", "throbbing", "sharp", "stout", "soundless", "neat",
			"swift", "uniform", "upright", "vibrant", "dingy", "vestigal",
			"messy", "sloppy", "baleful", "boastful", "dark", "capricious",
			"concrete", "deliberate", "sharp", "drunken", "undisciplined",
			"perfect", "bloated" ]);
		
		private const adverb: Vector.<String> = Vector.<String>([
			"randomly", "quickly", "triumphantly",
			"suggestively", "slowly", "angrily", "uncomfortably", "finally",
			"unexpectedly", "hysterically", "thinly", "dryly", "blazingly",
			"terribly", "bleakly", "irritably", "dazzlingly", "expectantly",
			"impersonally", "abruptly", "awfully", "caressingly", "completely",
			"undesirably", "drolly", "hypocritically", "blankly", "dimly" ]);
	}
}