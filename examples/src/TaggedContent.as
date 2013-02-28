package
{
	import flash.events.Event;
	
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.pdf.PdfStructureElement;
	import org.purepdf.pdf.PdfStructureTreeRoot;
	import org.purepdf.pdf.fonts.BaseFont;

	public class TaggedContent extends DefaultBasicExample
	{

		/** a string array with text. */
		public static const text1: Vector.<String> = Vector.<String>( [ "It was the best of times, it was the worst of times, ", "it was the age of wisdom, it was the age of foolishness, ",
				"it was the epoch of belief, it was the epoch of incredulity, ", "it was the season of Light, it was the season of Darkness, ", "it was the spring of hope, it was the winter of despair." ] );

		/** a string array with text. */
		public static const text2: Vector.<String> = Vector.<String>( [ "We had everything before us, we had nothing before us, ", "we were all going direct to Heaven, we were all going direct ",
				"the other way\u2014in short, the period was so far like the present ", "period, that some of its noisiest authorities insisted on its ",
				"being received, for good or for evil, in the superlative degree ", "of comparison only." ] );

		public function TaggedContent( d_list: Array = null )
		{
			super( ["Create a simple tagged pdf document"] );
			registerDefaultFont();
		}

		override protected function execute( event: Event = null ): void
		{
			super.execute();
			createDocument();

			// First of all set the tagged property to true
			writer.tagged = true;
			document.open();

			var k: int;
			var root: PdfStructureTreeRoot = writer.structureTreeRoot;

			// we call the root "Everything"
			var eTop: PdfStructureElement = PdfStructureElement.createRoot( root, new PdfName( "Everything" ) );

			// "Everything" is not a standard structure and must be mapped to a
			// standard one like "Sect"
			root.mapRole( new PdfName( "Everything" ), new PdfName( "Sect" ) );

			// "P" is a standard structure, no need to map
			var e1: PdfStructureElement = PdfStructureElement.createElement( eTop, PdfName.P );
			var e2: PdfStructureElement = PdfStructureElement.createElement( eTop, PdfName.P );
			var e3: PdfStructureElement = PdfStructureElement.createElement( eTop, PdfName.P );

			// we grab the direct content and create a font
			var cb: PdfContentByte = document.getDirectContent();
			var bf: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false );
			cb.setLeading( 16 );
			cb.setFontAndSize( bf, 12 );

			// the paragraph is contained in a single sequence
			cb.beginMarkedContentSequence( e1 );
			cb.beginText();
			cb.setTextMatrix( 1, 0, 0, 1, 50, 790 );

			for ( k = 0; k < text1.length; ++k )
				cb.newlineShowText( text1[k] );
			cb.endText();
			cb.endMarkedContentSequence();

			// the paragraph is contained in several sequences but logically is
			// a single sequence
			cb.beginText();
			cb.setTextMatrix( 1, 0, 0, 1, 50, 700 );
			for ( k = 0; k < 2; ++k )
			{
				cb.beginMarkedContentSequence( e2 );
				cb.newlineShowText( text2[k] );
				cb.endMarkedContentSequence();
			}
			cb.endText();
			document.newPage();
			cb.setLeading( 16 );
			cb.setFontAndSize( bf, 12 );
			cb.beginText();
			cb.setTextMatrix( 1, 0, 0, 1, 50, 804 );
			for ( k = 2; k < text2.length; ++k )
			{
				cb.beginMarkedContentSequence( e2 );
				cb.newlineShowText( text2[k] );
				cb.endMarkedContentSequence();
			}
			cb.endText();

			// text replacement - the word "best" will be replaced by "worst" when extracting text
			cb.beginMarkedContentSequence( e3 );
			cb.beginText();
			cb.setTextMatrix( 1, 0, 0, 1, 50, 400 );
			cb.showText( "It was the " );
			var dic: PdfDictionary = new PdfDictionary();
			dic.put( new PdfName( "ActualText" ), new PdfString( "best" ) );
			cb.beginMarkedContentSequence2( new PdfName( "Span" ), dic, true );
			cb.showText( "worst" );
			cb.endMarkedContentSequence();
			cb.showText( " of times." );
			cb.endText();
			cb.endMarkedContentSequence();

			document.close();
			save();
		}
	}
}