
import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.models.VideoObject;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.media.StageWebView;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;

private var webView:StageWebView;

private var topVideos:ArrayCollection;

public function doWork():void{
	getTopVideos();
}

private function getTopVideos():void{	
	if(mse != null && videoList.dataProvider != null){
		this.dispatchEvent(new Event(Event.COMPLETE));
		return;
	}
	
	if(mse == null)
		mse = FlexGlobals.topLevelApplication.mse;
	
	mse.addEventListener(Event.COMPLETE, onVideos);
	mse.getTopVideos();
}

private function onVideos(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onVideos);
	
	topVideos = new ArrayCollection(mse.videos);
	videoList.dataProvider = topVideos;
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onSearchKeyUp(e:KeyboardEvent):void{
	if(e.keyCode == Keyboard.ENTER && searchInput.text.length > 1){
		mse.addEventListener(Event.COMPLETE, onSearch);
		mse.findVideo(searchInput.text);
		
		FlexGlobals.topLevelApplication.loadingOn();
		
		searchInput.text = '';
	}else if(e.keyCode == Keyboard.ESCAPE && searchInput.text.length < 1){
		videoList.dataProvider = topVideos;
	}
}

private function onSearch(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSearch);
	
	FlexGlobals.topLevelApplication.loadingOff();
	
	videoList.dataProvider = new ArrayCollection(mse.videos);
}

public function playVideo(v:VideoObject):void{	
	// hide search UI
	FlexGlobals.topLevelApplication.musicPlayer.visible =
	searchUI.visible = false;
	
	// show video close button
	videoCloseButton.visible = true;
	
	// show video
	webView = new StageWebView();
	webView.stage = this.stage;
	webView.viewPort = new Rectangle(0, 20, this.stage.stageWidth, this.stage.stageHeight-20);
	webView.loadURL(v.contentURL);
}

private function closeVideo():void{
	webView.dispose();
	webView = null;
	
	videoCloseButton.visible = false;
	
	FlexGlobals.topLevelApplication.musicPlayer.visible =
	searchUI.visible = true;
}

public function findVideo(query:String):void{
	if(mse == null)
		mse = FlexGlobals.topLevelApplication.mse;
	
	mse.addEventListener(Event.COMPLETE, onVideoSearch);
	mse.findVideo(query);
	
	FlexGlobals.topLevelApplication.loadingOn();
}

private function onVideoSearch(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onVideoSearch);
	
	FlexGlobals.topLevelApplication.loadingOff();
	
	videoList.dataProvider = new ArrayCollection(mse.videos);
	
	FlexGlobals.topLevelApplication.changeView(this);
}