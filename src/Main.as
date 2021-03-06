package 
{
	import com.stimuli.loading.BulkProgressEvent;
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.ProgressBar;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Slider;
	import feathers.controls.TextInput;
	import feathers.core.ITextRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.layout.ViewPortBounds;
	import feathers.themes.MetalWorksMobileTheme;
	import feathers.controls.text.TextFieldTextRenderer;
	import flash.events.ErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import neoart.flod.FileLoader;

	import starling.display.Sprite;
	import starling.events.Event;
	
	import neoart.flod.core.*;
	import com.stimuli.loading.BulkLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;

	public class Main extends Sprite
	{
		public var gctrllay:VerticalLayout;
		public var gcont:ScrollContainer;
		
		public var ctrllay:HorizontalLayout;
		public var cont:ScrollContainer;
		
		[Embed(source = "mod/Monday.mod", mimeType = "application/octet-stream")]
		public var TESTFILE:Class;
		
		//Buttons
		public var rewbtn:Button;
		public var playbtn:Button;
		public var ffbtn:Button;
		public var stopbtn:Button;
		public var go:Button;
		public var about:Button;
		
		public var url:TextInput;
		public var bar:ProgressBar;
		public var vol:Slider;
		
		public var player:CorePlayer;
		public var loader:FileLoader;
		
		public var playing:Boolean = false;
		public var urlstr:String = "http";
		public var volume:Number = 100.0;
		
		public var dloader:BulkLoader;
		public var context:LoaderContext;
		
		public function Main()
		{
			context = new LoaderContext(false);
			
			//Flod
			loader = new FileLoader;
			player = loader.load(new TESTFILE as ByteArray);
			
			//BulkLoader
			dloader = new BulkLoader("track");
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			new MetalWorksMobileTheme(null, false);
			
			gctrllay = new VerticalLayout;
			gctrllay.paddingTop = 10;
			gctrllay.paddingRight = 15;
			gctrllay.paddingBottom = 10;
			gctrllay.paddingLeft = 15;
			gctrllay.gap = 5;
			gctrllay.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_LEFT;
			gctrllay.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			
			gcont = new ScrollContainer;
			gcont.layout = gctrllay;
			
			ctrllay = new HorizontalLayout;
			ctrllay.paddingTop = 10;
			ctrllay.paddingRight = 15;
			ctrllay.paddingBottom = 10;
			ctrllay.paddingLeft = 15;
			ctrllay.gap = 5;
			ctrllay.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			ctrllay.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			
			
			cont = new ScrollContainer;
			cont.layout = ctrllay;
			
			addChild(gcont);
			
			//Btns
			rewbtn = new Button();
			rewbtn.label = "Last";
			
			playbtn = new Button();
			playbtn.label = "Play/Pause";
			
			ffbtn = new Button();
			ffbtn.label = "Next";
			
			stopbtn = new Button();
			stopbtn.label = "Stop";
			
			go = new Button();
			go.label = "Download&Play";
			
			about = new Button();
			about.label = "About";
			
			url = new TextInput;
			
			bar = new ProgressBar;
			
			vol = new Slider;
			
			//Adding btns
			//cont.addChild(rewbtn);
			//rewbtn.validate();
			
			vol.minimum = 0;
			vol.maximum = 100;
			vol.value = 50;
			vol.step = 2;
			vol.page = 10;
			gcont.addChild(vol);
			
			gcont.addChild(cont);
			
			cont.addChild(playbtn);
			playbtn.validate();
			
			//cont.addChild(ffbtn);
			//ffbtn.validate();
			
			cont.addChild(stopbtn);
			stopbtn.validate();
			
			cont.addChild(go);
			go.validate();
			
			gcont.addChild(url);
			url.text = "Download URL";
			//url.isEditable = false;
			url.validate();
			
			gcont.addChild(bar);
			bar.visible = false;
			bar.maximum = 1.0;
			bar.minimum = 0.0
			
			gcont.addChild(about);
			
			playbtn.addEventListener(Event.TRIGGERED, playpause);
			stopbtn.addEventListener(Event.TRIGGERED, stop);
			about.addEventListener(Event.TRIGGERED, help);
			go.addEventListener(Event.TRIGGERED, dltrack);
			url.addEventListener(Event.CHANGE, seturl);
			vol.addEventListener(Event.CHANGE, setvol);
			//ffbtn.addEventListener(Event.TRIGGERED, fforward);
		}
		
		protected function playpause(event:Event):void
		{
			if (playing) 
			{
				playing = false;
				player.pause();
			}
			
			else 
			{
				playing = true;
				player.play();
			}
		}
		
		protected function stop(event:Event):void
		{
			player.stop();
		}
		
		protected function help(event:Event):void
		{
			navigateToURL(new URLRequest("https://github.com/Ohmnivore/BitPlayerWeb"), '_self');
		}
		
		protected function fforward(event:Event):void
		{
			//player.fast();
			//player.tempo = 200;
		}
		
		protected function seturl(event:Event):void
		{
			urlstr = event.target["text"];
		}
		
		protected function setvol(event:Event):void
		{
			volume = event.target["value"];
			player.volume = volume / 100.0;
		}
		
		protected function dltrack(event:Event):void
		{
			dloader.add(urlstr, {context:context, id:"gettrack", type:"binary", dataFormat:URLLoaderDataFormat.BINARY});
			
			dloader.get("gettrack").addEventListener(Event.COMPLETE, onTrackLoaded);
			dloader.get("gettrack").addEventListener(BulkLoader.PROGRESS, onProgress);
			dloader.get("gettrack").addEventListener(BulkLoader.ERROR,dlError);
			
			dloader.start();
			
			bar.visible = true;
		}
		
		function dlError(evt:ErrorEvent):void
		{
			trace (evt); // outputs more information
			var cont:Label = new Label;
			cont.text = evt.text;
			var pop:Alert = Alert.show(evt.text, "Error on download", new ListCollection(
			[
				{ label: "OK" }
			]));
			dloader.removeAll();
			bar.visible = false;
		}
		
		protected function onProgress(e:BulkProgressEvent):void
		{
			var p:Number = e.percentLoaded;
			bar.value = p;
		}
		
		protected function onTrackLoaded(e):void
		{
			try
			{
				var track = dloader.getContent("gettrack");
				
				try { player.stop(); }
				catch (e) { }
				
				loader = new FileLoader;
				player = loader.load(track);
				dloader.removeAll();
				
				player.play();
				playing = true;
			}
			
			catch (e:Error)
			{
				var pop:Alert = Alert.show("Unsupported file type", 
					"Error on play", new ListCollection(
				[
					{ label: "OK" }
				]));
				dloader.removeAll();
				
				try { player.stop(); }
				catch (e) {}
				playing = false;
			}
			
			bar.visible = false;
		}
	}
}
