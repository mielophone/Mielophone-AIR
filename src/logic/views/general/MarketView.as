
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileReference;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

import mielophone.ui.views.search.ArtistSearchView;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.utils.ObjectUtil;
import mx.utils.object_proxy;

private const MARKET_URL:String = "http://mielophone.github.com/market.xml";

[Bindable]
private var plugins:Array;

private var request:URLRequest; 
private var stream:URLStream;
private var fileStream:FileStream;
private var file:File;

private var downloadPath:String;
private var downloadFile:String;

public function doWork():void{
	this.dispatchEvent(new Event(Event.COMPLETE));
}

public function fetchPlugins():void{
	var urlReq:URLRequest = new URLRequest(MARKET_URL);
	var urlLoader:URLLoader = new URLLoader();
	urlLoader.addEventListener(Event.COMPLETE, onMarketData);
	urlLoader.load(urlReq);
}

private function onMarketData(e:Event):void{
	e.target.removeEventListener(Event.COMPLETE, onMarketData);
	// new plugins
	plugins = [];
	// get installed plugins
	var installedPlugins:Array = FlexGlobals.topLevelApplication.mse.getActivePlugins();
	
	var newPluginsCount:int = 0;
	
	// parse xml
	var xml:XML = new XML(e.target.data);
	var plugin:XML, isInstalled:Boolean, i:int;
	for each(plugin in xml.children()){
		isInstalled = false;
		// detect if plugin is installed
		for(i = 0; i < installedPlugins.length; i++){
			if( plugin.@name == installedPlugins[i].name ){
				isInstalled = true;
				break;
			}
		}
		// append
		plugins.push({name: plugin.@name, author: plugin.@author, description: plugin.@description, url: plugin.@url, installed:isInstalled});
		if(!isInstalled) newPluginsCount++;
	}
	
	if(newPluginsCount > 0) FlexGlobals.topLevelApplication.homeView.marketButton.newPlugins.text = newPluginsCount;
	
	pluginList.dataProvider = new ArrayCollection(plugins);
}

public function installPlugin(plugin:Object):void{
	if(plugin.installed){
		Alert.show("Plugin is already installed!", "Error!");
		return;
	}else{
		var url:String = plugin.url;
		var name:String = plugin.name;
		
		downloadProgress.visible = progressText.visible = true;
		
		fileStream = new FileStream();
		stream = new URLStream();
		
		stream.addEventListener(ProgressEvent.PROGRESS, onProgress);
		stream.addEventListener(Event.COMPLETE, onComplete);
		stream.addEventListener(IOErrorEvent.IO_ERROR, onError);
		
		downloadFile = url.substr(url.lastIndexOf("/"));
		
		trace(downloadFile);
		
		file = File.desktopDirectory.resolvePath( File.applicationStorageDirectory.resolvePath("plugins/").nativePath+downloadFile );
		trace(file.nativePath);
		request = new URLRequest(url);
		fileStream.openAsync(file, FileMode.WRITE);
		
		stream.load(request);
	}
}

private function onProgress(e:ProgressEvent):void{
	var byteArray:ByteArray = new ByteArray();
	var value:Number = e.bytesLoaded;
	var total:Number = e.bytesTotal;
	var precent:Number = Math.round(value*100/total);
	
	stream.readBytes(byteArray, 0, stream.bytesAvailable);
	fileStream.writeBytes(byteArray, 0, byteArray.length);
	
	downloadProgress.setProgress( e.bytesLoaded, e.bytesTotal );
}

private function onComplete(e:Event):void{
	fileStream.close();
	stream.close(); 
	
	downloadProgress.visible = progressText.visible = false;
	Alert.show("Please, restart to enable new plugin", "Plugin download complete!");
}

private function onError(e:Event):void{
	downloadProgress.visible = progressText.visible = false;
	Alert.show("Something went wrong, try again.", "Error downloading plugin!");
}