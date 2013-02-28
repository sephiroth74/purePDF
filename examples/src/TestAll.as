package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.getQualifiedClassName;
	
	import org.purepdf.elements.MultiColumnText;

	public class TestAll extends DefaultBasicExample
	{
		protected var class_list: Vector.<Class> = new Vector.<Class>();
		protected var filelist: Vector.<Array> = new Vector.<Array>();
		protected var total_number: int;
		protected var current_test_number: int = 0;
		protected var skip_button: Sprite;
		
		protected var current: DefaultBasicExample;

		public function TestAll()
		{
			super();
			
			class_list.push( AnimatedGif );
			class_list.push( ClippingPath );
			class_list.push( DrawingPaths );
			class_list.push( GraphicState );
			class_list.push( ImageTypes );
			class_list.push( Transparency );
			class_list.push( BitmapDataTransparency );
			class_list.push( Layers );
			class_list.push( LineStyles );
			class_list.push( Patterns );
			class_list.push( SeparationColors );
			class_list.push( ShadingPatterns );
			class_list.push( ShadingMultipleColors );
			class_list.push( ShadingGradientTransparency );
			class_list.push( SimpleAnnotation );
			class_list.push( SimpleAnnotation2 );
			class_list.push( ImageAnnotation );
			class_list.push( SlideShow );
			class_list.push( ViewerExample );
			class_list.push( HelloWorld );
			class_list.push( HelloWorld2 );
			class_list.push( HelloWorld3 );
			class_list.push( HelloWorld4 );
			class_list.push( HelloWorld5 );
			class_list.push( HelloWorldFullCompression );
			class_list.push( HelloWorldAnchor );
			class_list.push( HelloWorldInternalAnchor );
			class_list.push( HelloWorldBookmark );
			class_list.push( HelloWorldTTF );
			class_list.push( HelloWorldMaximum );
			class_list.push( HelloWorldChapterAutoNumber );
			class_list.push( HelloChunk );
			class_list.push( HelloSplitCharacter );
			class_list.push( HelloWorldGoto );
			class_list.push( ImageBitmapData );
			class_list.push( AnnotatedChunk );
			class_list.push( ChunkSkew );
			class_list.push( ChunkHorizontalScale );
			class_list.push( GenericTag );
			class_list.push( LayerMembershipExample );
			class_list.push( ListExample1 );
			class_list.push( ListExample2 );
			class_list.push( ParagraphExample );
			class_list.push( PhraseExample );
			class_list.push( TextRender );
			class_list.push( FlyerExample );
			class_list.push( BarCodes );
			class_list.push( PdfPTableExample1 );
			class_list.push( TableExample2 );
			class_list.push( PdfPTableAbsoluteColumns );
			class_list.push( PdfPTableAbsolutePositions );
			class_list.push( PdfPTableAligned );
			class_list.push( PdfPTableCellHeights );
			class_list.push( PdfPTableColors );
			class_list.push( PdfPTableColumnWidths );
			class_list.push( PdfPTableCompare );
			class_list.push( PdfPTableImages );
			class_list.push( PdfPTableMemoryFriendly );
			class_list.push( RegistrationForm );
			class_list.push( HeaderFooter1 );
			class_list.push( HeaderFooter2 );
			class_list.push( HeaderFooter3 );
			class_list.push( SimpleTextField );
			class_list.push( HelloUnicode );
			class_list.push( ChineseKoreanJapanese );
			class_list.push( Javascript1 );
			class_list.push( Javascript2 );
			class_list.push( Calculator );
			class_list.push( ArabicText );
			class_list.push( MultiColumnPoem );
			class_list.push( MultiColumnIrregular );
			class_list.push( FileAttachment1 );
			class_list.push( RotatePage );
			class_list.push( PageLabels );
			class_list.push( TaggedContent );
			class_list.push( ColumnTextExample );
			class_list.push( Kalligraphy );
			class_list.push( ReadOutLoud );
			class_list.push( TooltipExample );
			class_list.push( Annotations );
			class_list.push( FormWithTooltip );
			class_list.push( NestingList );
			class_list.push( VerticalTextExample );
			class_list.push( WMFImage );
			class_list.push( BitmapImageSample );
			class_list.push( KoreanNotEmbed );
			class_list.push( KoreanEmbed );
			class_list.push( MultiPageTiff );
			
			total_number = class_list.length;
		}

		override protected function createchildren(): void
		{
			description_container = new Sprite();
			addChild( description_container );
			
			create_class();
		}
		
		protected function create_class(): void
		{
			if ( class_list.length == 0 )
				return;

			current_test_number++;
			
			var cls: Class = class_list.shift();
			current = new cls();
			
			create_default_button( "(" + current_test_number + " of " + total_number + ") " + getQualifiedClassName( current ) );
			create_skip_button();
			
			createDescription();
		}
		
		protected function create_skip_button(): void
		{
			skip_button = createButton( 0x009900, "skip »", skipTest );
			center( skip_button, create_button );
			addChild( skip_button );
		}
		
		override internal function createDescription() : void
		{
			if( current )
			{
				description( current.description_list );
			}
		}
		
		protected function skipTest( event: Event ): void
		{
			execute_next();
		}

		override protected function execute( event: Event=null ): void
		{
			super.execute();

			var result: Array = current.executeAll();

			end_time = new Date().getTime();
			addResultTime( end_time - start_time );


			var f: FileReference = new FileReference();
			f.addEventListener( Event.COMPLETE, onSaveComplete );
			f.save( result[ 1 ], result[ 0 ] );

		}


		private function execute_next(): void
		{
			if ( create_button )
			{
				removeChild( create_button );
				create_button = null;
			}
			
			if( skip_button )
			{
				removeChild( skip_button );
				skip_button = null;
			}

			clear_message();

			if ( class_list.length == 0 )
				return;
			
			create_class();
		}

		private function onSaveComplete( e: Event ): void
		{
			execute_next();
		}
	}
}