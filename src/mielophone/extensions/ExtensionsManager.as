package mielophone.extensions
{
	import com.codezen.helper.Worker;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import mx.utils.ObjectUtil;

	public final class ExtensionsManager extends Worker
	{
		// plugins array
		private var _plugins:Array;
		
		// loaders
		private var urlReq:URLRequest;			
		private var urlLoad:URLLoader;
		private var loader:Loader;
		
		// load queue
		private var _loadQueue:Array;
		
		// plugins dir
		private var _dirs:Array;
		// file class
		private var _file:File;
		
		// context
		private var context:LoaderContext;
		
		// counter
		private var dircounter:int;
		private var counter:int;
		
		public function ExtensionsManager(dirs:Array)
		{
			// save dir
			_dirs = dirs.concat();
			
			// init plugins array
			_plugins = [];			
			
			// load plugins
			dircounter = _dirs.length;
			loadPlugins();
		}
		
		private function loadPlugins():void{
			dircounter--;
			if(dircounter < 0){
				dispatchEvent(new Event(Event.INIT));
				return;
			}
			_file = new File(_dirs[dircounter]);
			if(!_file.exists){
				loadPlugins();
				return;
			}
			_file.addEventListener(FileListEvent.DIRECTORY_LISTING, onListing);
			//_file.addEventListener(IOErrorEvent.IO_ERROR, onFolderError);
			_file.getDirectoryListingAsync();
		}
		
		// parse listing of files
		private function onListing(e:FileListEvent):void{
			var contents:Array = e.files;
			
			_loadQueue = [];
			
			var cFile:File;
			for (var i:int = 0; i < contents.length; i++) {
				cFile = contents[i] as File;
				_loadQueue.push(cFile.url);
				//loadPluginFromPath(cFile.url);
			}
			
			counter = _loadQueue.length;
			loadPluginsFromPath();
		}
		
		// load plugin from path
		private function loadPluginsFromPath():void{
			var path:String = _loadQueue[ _loadQueue.length - counter ];
			urlReq = new URLRequest(path);			
			urlLoad = new URLLoader();
			urlLoad.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoad.addEventListener(Event.COMPLETE, onPluginData);
			urlLoad.load(urlReq);
		}
		
		private function onPluginData(e:Event):void{
			urlLoad.removeEventListener(Event.COMPLETE, onPluginData);
			
			// create context
			context = new LoaderContext(false, ApplicationDomain.currentDomain );
			context.allowCodeImport = true;
			context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			// create loader
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPluginLoaded);
			loader.loadBytes(urlLoad.data, context);
		}
		
		private function onPluginLoaded(e:Event):void{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onPluginLoaded);
			
			var className:Class = loader.contentLoaderInfo.applicationDomain.getDefinition("MUIExtension") as Class;
			var classInstance:IMUIExtension = new className();
			_plugins.push(classInstance);
			
			checkInit();
		}
		
		private function checkInit():void{
			counter--;
			if(counter <= 0){
				if(dircounter <= 0){
					trace( 'ui done: '+ObjectUtil.toString(_plugins) );
					
					dispatchEvent(new Event(Event.INIT));
				}else{
					loadPlugins();
				}
			}else{
				loadPluginsFromPath();
			}
		}
		
		// ---------------------------------------------
		public function listPlugins():Array{
			var searcher:IMUIExtension;
			var i:int;
			var res:Array = [];
			for(i = 0; i < _plugins.length; i++){
				searcher = _plugins[i] as IMUIExtension;
				res.push({index: i+1, name: searcher.PLUGIN_NAME, author: searcher.AUTHOR_NAME});
			}
			
			return res;
		}
	}
}