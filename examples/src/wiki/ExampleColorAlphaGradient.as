package wiki
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	import org.purepdf.colors.GrayColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfGState;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfShading;
	import org.purepdf.pdf.PdfShadingPattern;
	import org.purepdf.pdf.PdfTemplate;
	import org.purepdf.pdf.PdfTransparencyGroup;
	import org.purepdf.pdf.PdfWriter;
	
	[SWF(frameRate="60",width="400",height="300")]
	public class ExampleColorAlphaGradient extends Sprite
	{
		public function ExampleColorAlphaGradient()
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
		}
		
		protected const SPRITE_W: Number = 300;
		protected const SPRITE_H: Number = 75;
		
		protected var sprite: Sprite;
		protected var frame: int = -1;
		protected var colors: Array;
		protected var alphas: Array;
		protected var ratios: Array;
		protected var gradient_rotation: Number = 0;
		protected var gradient_rect: Rectangle = new Rectangle( 0, 0, SPRITE_W/2, SPRITE_H/2);
		protected var text: TextField;
		
		// pdf properties
		private var cb_colors: Vector.<RGBColor>;
		private var cb_ratios: Vector.<Number>;
		private var cb_alphas: Vector.<Number>;
		
		
		protected function onAdded( event: Event ): void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			sprite = new Sprite();
			sprite.graphics.beginFill( 0, 0.5 );
			sprite.graphics.drawRect( 0, 0, SPRITE_W, SPRITE_H );
			sprite.graphics.endFill();
			
			colors = [ 0xFF0000, 0x0000FF, 0x00FF00 ];
			alphas = [ 1, 1, 1 ];
			ratios = [ 0, 127, 255 ];
			
			sprite.buttonMode = true;
			sprite.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			addChild( sprite );

			onEnterFrame( null );
			
			// pdf
			cb_colors = Vector.<RGBColor>([RGBColor.fromARGB( 0xFFFF0000 ), RGBColor.fromARGB( 0xFF0000FF ), RGBColor.fromARGB( 0xFF00FF00 )]);
			cb_ratios = Vector.<Number>( [0, 0.49, 1]);
			cb_alphas = Vector.<Number>(alphas);
			
			text = new TextField();
			text.defaultTextFormat = new TextFormat("_sans", 16, 0, null, null, null, null, null, TextFormatAlign.CENTER );
			text.text = "Click to start/stop";
			text.width = 400;
			text.selectable = false;
			//addChild( text );
		}
		
		protected function onEnterFrame( event: Event ): void
		{
			frame++;
			frame = 0;
			
			var matrix: Matrix = new Matrix();
			matrix.identity();
			matrix.translate( -SPRITE_W/2, -SPRITE_H/2 );
			matrix.rotate( radians( -frame/1.5 ) );
			matrix.translate( 200 + ( 100 * Math.sin( frame/100 )), 150 + ( 75 * Math.cos( frame/100 ))  );
			//sprite.transform.matrix = matrix;
			
			//gradient_rect.x = Math.sin( frame/100 ) * 100;
			//gradient_rect.y = Math.cos( frame/100 ) * 100;
			gradient_rotation = radians( 45 );
			
			var gradient_matrix: Matrix = new Matrix();
			gradient_matrix.createGradientBox( gradient_rect.width, gradient_rect.height, gradient_rotation, gradient_rect.left, gradient_rect.top );
			sprite.graphics.clear();
			sprite.graphics.beginGradientFill( GradientType.LINEAR, colors, alphas, ratios, gradient_matrix );
			sprite.graphics.drawRoundRect( 0, 0, SPRITE_W, SPRITE_H, 10, 10 );
			sprite.graphics.endFill();
		}
		
		protected function onMouseDown( event: MouseEvent ): void
		{
			if( hasEventListener( Event.ENTER_FRAME ) )
			{
				removeEventListener( Event.ENTER_FRAME, onEnterFrame );
				save();
			} else {
				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
		}
		
		private function save(): void
		{
			var buffer: ByteArray = new ByteArray();
			var writer: PdfWriter = PdfWriter.create( buffer, PageSize.create( 400, 300 ) );
			var document: PdfDocument = writer.pdfDocument;
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			cb.setTransform( new Matrix( 1, 0, 0, -1, 0, 300 ) );			
			cb.saveState();
			cb.setTransform( sprite.transform.matrix );

			// Create the template first
			var template: PdfTemplate = cb.createTemplate( gradient_rect.width, gradient_rect.height );
			var transGroup: PdfTransparencyGroup = new PdfTransparencyGroup();
			transGroup.put( PdfName.CS, PdfName.DEVICERGB );
			transGroup.isolated = true;
			transGroup.knockout = false;
			template.group = transGroup;
			
			var gState: PdfGState = new PdfGState();
			var maskDict: PdfDictionary = new PdfDictionary();
			maskDict.put( PdfName.TYPE, PdfName.MASK );
			maskDict.put( PdfName.S, new PdfName( "Luminosity" ) );
			maskDict.put( new PdfName( "G" ), template.indirectReference );
			gState.put( PdfName.SMASK, maskDict );
			//cb.setGState( gState );
			
			var sprite_matrix: Matrix = sprite.transform.matrix.clone();
			var pattern_matrix: Matrix = new Matrix();
			var template_matrix: Matrix = new Matrix();
			
			// TEMPLATE
			var alphas: Vector.<GrayColor> = new Vector.<GrayColor>( cb_alphas.length, true );
			for ( var k: int = 0; k < cb_alphas.length; ++k )
				alphas[k] = new GrayColor( cb_alphas[k] );
			
			var template_shading: PdfShading = PdfShading.complexAxial( cb.writer, 0, 0, gradient_rect.width, 0, Vector.<RGBColor>( alphas ), cb_ratios );
			var template_pattern: PdfShadingPattern = new PdfShadingPattern( template_shading );
			
			//template_matrix.translate( -gradient_rect.width/2, -gradient_rect.height/2 );
			template_matrix.rotate( gradient_rotation );
			//template_matrix.translate( gradient_rect.left + gradient_rect.width/2, gradient_rect.top + gradient_rect.height/2 );
			
			template_pattern.matrix = template_matrix;
			template.rectangle( 0, 0, gradient_rect.width, gradient_rect.height );
			template.setShadingFill( template_pattern );
			template.fill();
			
			
			// CONTENT
			//pattern_matrix.translate( -gradient_rect.width/2, -gradient_rect.height/2 );
			pattern_matrix.rotate( gradient_rotation );
			//pattern_matrix.translate( gradient_rect.x + gradient_rect.width/2, gradient_rect.y + gradient_rect.height/2 );
			//pattern_matrix.concat( sprite_matrix );
			trace( sprite_matrix );
			pattern_matrix.concat( new Matrix( 1, 0, 0, -1, 0, 300 ) );
			
			var r: Rectangle = gradient_rect.clone();
			var top_left: Point = pattern_matrix.transformPoint( r.topLeft );
			var bottom_right: Point = pattern_matrix.transformPoint( r.bottomRight );
			
			//trace( top_left, bottom_right );
			
			var cb_shading: PdfShading = PdfShading.complexAxial( cb.writer, top_left.x, top_left.y, bottom_right.x, bottom_right.y, cb_colors, cb_ratios );
			var cb_pattern: PdfShadingPattern = new PdfShadingPattern( cb_shading );
			//cb_pattern.matrix = pattern_matrix.clone();

			cb.roundRectangle( 0, 0, SPRITE_W, SPRITE_H, 5 );
			cb.setShadingFill( cb_pattern );
			cb.fill();
			
			cb.restoreState();
			document.close();
			
			var f: FileReference = new FileReference();
			f.save( buffer, "gradient_alpha.pdf" );
		}
		
		public static function degrees( radians: Number ): Number
		{
			return radians * ( 180 / Math.PI );
		}
		
		public static function radians( degree: Number ): Number
		{
			return degree * ( Math.PI / 180 );
		}		
	}
}