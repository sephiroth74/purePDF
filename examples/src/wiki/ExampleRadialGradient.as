package wiki
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
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
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.ByteArray;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfShading;
	import org.purepdf.pdf.PdfShadingPattern;
	import org.purepdf.pdf.PdfWriter;
	
	[SWF(frameRate="60",width="600",height="400")]
	public class ExampleRadialGradient extends Sprite
	{
		public function ExampleRadialGradient()
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
		}
		
		protected var SPRITE_W: Number;
		protected var SPRITE_H: Number;
		protected var STAGE_W: Number;
		protected var STAGE_H: Number;
		protected var GRADIENT_W: Number;
		protected var GRADIENT_H: Number;
		
		protected var sprite: Sprite;
		protected var frame: int = -1;
		protected var gradient_matrix: Matrix;
		protected var colors: Array;
		protected var alphas: Array;
		protected var ratios: Array;
		protected var gradient_rotation: Number = 0;
		protected var gradient_rect: Rectangle;
		protected var focalPoint: Number = 0;
		
		protected var pair_x: Number;
		protected var pair_y: Number;
		
		// pdf properties
		private var cb_colors: Vector.<RGBColor> = new Vector.<RGBColor>();
		private var cb_ratios: Vector.<Number> = new Vector.<Number>();
		
		private var test_sprite: Sprite;
		private var temp_sprite: Sprite;
		
		protected function updateEnv(): void
		{
			STAGE_W = stage.stageWidth;
			STAGE_H = stage.stageHeight;
			
			SPRITE_W = STAGE_W/2.2;
			SPRITE_H = STAGE_H/3;
			GRADIENT_W = SPRITE_W * 2.1;
			GRADIENT_H = SPRITE_H * 1.5;
			
			gradient_rect = new Rectangle( 0, 0, GRADIENT_W, GRADIENT_H );
		}
		
		protected function onAdded( event: Event ): void
		{
			//stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			updateEnv();
			
			sprite = new Sprite();
			sprite.graphics.beginFill( 0, 0.5 );
			sprite.graphics.drawRect( 0, 0, SPRITE_W, SPRITE_H );
			sprite.graphics.endFill();
			
			gradient_matrix = new Matrix();
			colors = [ 0xFF0000, 0x00FF00, 0xFF00FF, 0xFFFFFF, 0x00FFFF ];
			alphas = [ 1, 1, 1, 1, 1 ];
			ratios = [ 0, 51, 130, 180, 255 ];
			
			sprite.buttonMode = true;
			sprite.addEventListener( MouseEvent.CLICK, onClick );
			addChild( sprite );
			
			// pdf
			for( var k: int = 0; k < colors.length; ++k )
			{
				cb_colors[k] = RGBColor.fromARGB( 0xFFFFFFFF & colors[k] );
				cb_ratios[k] = ratios[k]/255;
			}
			
			var msg_format: ElementFormat = new ElementFormat();
			msg_format.fontDescription = new FontDescription("Helvetica");
			msg_format.fontSize = 12;
			msg_format.color = 0x000000;
			
			var block: TextBlock = new TextBlock();
			block.content = new TextElement("Click the sprite to start/stop", msg_format);
			var message_line: TextLine = block.createTextLine();
			
			message_line.x = ( STAGE_W - message_line.width ) / 2;
			message_line.y = message_line.height;
			message_line.mouseChildren = false;
			message_line.mouseEnabled = false;
			addChild( message_line );
			
			test_sprite = new Sprite();
			test_sprite.mouseEnabled = false;
			addChild( test_sprite );
			
			temp_sprite = new Sprite();
			temp_sprite.mouseEnabled = false;
			addChild( temp_sprite );
			
			onEnterFrame( null );
		}
		
		protected function onEnterFrame( event: Event ): void
		{
			frame++;
			var matrix: Matrix = new Matrix();
			matrix.identity();
			matrix.translate( -SPRITE_W/2, -SPRITE_H/2 );
			matrix.b = matrix.c = Math.sin( frame/100 );
			matrix.rotate( radians( -frame/1.5 ) );
			matrix.translate( (STAGE_W/2) + ( 100 * Math.sin( frame/100 )), (STAGE_H/2) + ( 75 * Math.cos( frame/100 ))  );
			
			sprite.transform.matrix = matrix;
			gradient_rect.x = (Math.sin( frame/100 ) * 100) + (( SPRITE_W-GRADIENT_W)/2);
			gradient_rect.y = (Math.cos( frame/100 ) * 100) + (( SPRITE_H-GRADIENT_H)/2);
			focalPoint = Math.sin( frame/80 );
			//focalPoint = 1;
			
			var test: Matrix = new Matrix();
			test = GradientMatrix.getGradientBox( GRADIENT_W, GRADIENT_H, 0, gradient_rect.x, gradient_rect.y );
			pair_x = 1/test.a;
			pair_y = 1/test.d;
			
			
			gradient_rotation = radians( frame );
			gradient_matrix = GradientMatrix.getGradientBox( GRADIENT_W, GRADIENT_H, gradient_rotation, gradient_rect.x, gradient_rect.y );
			sprite.graphics.clear();
			sprite.graphics.beginGradientFill( GradientType.RADIAL, colors, alphas, ratios, gradient_matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB, focalPoint );
			sprite.graphics.drawRoundRect( 0, 0, SPRITE_W, SPRITE_H, 10, 10 );
			sprite.graphics.endFill();
			update();
		}
		
		protected function onClick( event: MouseEvent ): void
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
			PdfDocument.compress = false;
			
			var buffer: ByteArray = new ByteArray();
			var writer: PdfWriter = PdfWriter.create( buffer, PageSize.create( STAGE_W, STAGE_H ) );
			var document: PdfDocument = writer.pdfDocument;
			document.open();
			var cb: PdfContentByte = document.getDirectContent();
			
			cb.setTransform( new Matrix( 1, 0, 0, -1, 0, STAGE_H ) );
			cb.saveState();
			cb.setTransform( sprite.transform.matrix );
			
			var matrix: Matrix = new Matrix();
			matrix.translate( -GRADIENT_W/2, -GRADIENT_H/2 );
			matrix.translate( -gradient_rect.x, -gradient_rect.y );
			matrix.scale( pair_x, pair_y );
			
			var box: Rectangle = gradient_rect.clone();
			matrix.concat( gradient_matrix );
			matrix.concat( sprite.transform.matrix );
			matrix.concat( new Matrix( 1, 0, 0, -1, 0, STAGE_H ) );
			
			var inner: Point = new Point( box.left + (box.right-box.left)/2, box.bottom + (box.top-box.bottom)/2 );
			var outer: Point = inner.clone();
			inner = inner.add( new Point( (box.width/2)*focalPoint, 0 ) );
			
			var m2: Matrix = new Matrix();
			m2.translate( 0, -GRADIENT_H/2  -box.top );
			m2.scale( 1, GRADIENT_H/GRADIENT_W);
			m2.translate( 0, (GRADIENT_H/2) + box.top );
			m2.concat( matrix );
			
			var shading: PdfShading = PdfShading.complexRadial( writer, inner.x, inner.y, outer.x, outer.y, 0, box.width/2, cb_colors, cb_ratios, true, true );
			var pattern: PdfShadingPattern = new PdfShadingPattern( shading );
			pattern.matrix = m2;
			
			cb.roundRectangle( 0, 0, SPRITE_W, SPRITE_H, 5 );
			cb.setShadingFill( pattern );
			cb.fill();
			cb.restoreState();
			
			document.close();
			
			var f: FileReference = new FileReference();
			f.save( buffer, "ExampleRadialGradient.pdf" );			
		}
		
		private function update(): void
		{
			test_sprite.graphics.clear();
			test_sprite.graphics.beginFill( 0, 0.05 );
			test_sprite.graphics.drawEllipse( 0, 0, GRADIENT_W, GRADIENT_H );
			
			var matrix: Matrix = new Matrix();
			matrix.translate( -GRADIENT_W/2, -GRADIENT_H/2 );
			matrix.scale( pair_x, pair_y );
			
			var box: Rectangle = gradient_rect.clone();
			
			matrix.concat( gradient_matrix );
			matrix.concat( sprite.transform.matrix );
			
			test_sprite.transform.matrix = matrix;
			test_sprite.graphics.endFill();
		}
		
		public static function radians( degree: Number ): Number
		{
			return degree * ( Math.PI / 180 );
		}
	}
}