
import com.codezen.mse.MusicSearchEngine;
import com.codezen.util.CUtils;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.utils.ObjectUtil;

/******************************************************/
/**						IMAGES						 **/
/******************************************************/
[Bindable]
[Embed(source="/assets/player/play.png")]
private var playImg:Class;

[Bindable]
[Embed(source="/assets/player/pause.png")]
private var pauseImg:Class;

/******************************************************/
/**						VARS						 **/
/******************************************************/
[Bindable]
private var categoriesCollection:ArrayCollection;

private var radioSound:Sound;
private var radioChannel:SoundChannel;
private var currentRadioURL:String;
private var currentRadioTitle:String;
private var isPlaying:Boolean;

public function initRadio():void{
	isPlaying = false;
	currentRadioURL = null;
}

public function doWork():void{
	var urlRequest:URLRequest = new URLRequest("http://mielophone.github.com/stations.xml");
	
	var urlLoader:URLLoader = new URLLoader();
	urlLoader.addEventListener(Event.COMPLETE, onStations);
	urlLoader.load(urlRequest);
}

private function onStations(e:Event):void{
	e.target.removeEventListener(Event.COMPLETE, onStations);
	
	var xml:XML = new XML(e.target.data);	
	var groups:XMLList = xml.group;
	
	categoriesCollection = new ArrayCollection();
	
	var stations:Array;
	var stats:XMLList;
	var grp:XML, station:XML;
	for each(grp in groups){
		stats = grp.station;
		
		stations = [];
		for each(station in stats){
			stations.push({
				title: station.title.text(),
				tag: station.tag.text(),
				cover: station.cover.text(),
				type: station.type.text(),
				url: station.url.text()
			});
		}
		
		categoriesCollection.addItem({
			id: grp.@id, 
			title: grp.@title, 
			stations: stations
		});
	}
	
	categories.selectedIndex = 0;
	radioList.dataProvider = new ArrayCollection(categories.selectedItem.stations);
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onCategoryChange(e:Event):void{
	if(categories.selectedIndex < 0) return;
	
	radioList.dataProvider = new ArrayCollection(categories.selectedItem.stations);
}

public function toggleRadio():void{
	isPlaying = !isPlaying;
	
	if(isPlaying && currentRadioURL != null){
		radioSound = new Sound(new URLRequest(currentRadioURL));
		radioChannel = radioSound.play();
		playRadio.source = pauseImg;
		currentRadio.text = currentRadioTitle;
	}else if(!isPlaying){
		try{
			radioSound.close();
			radioSound = null;
			radioChannel.stop();
		}catch(e:Error){}
		
		playRadio.source = playImg;
		currentRadio.text = "Radio is off";
	}
}

public function playRadioURL(url:String, title:String):void{
	// stop player if it's playing
	FlexGlobals.topLevelApplication.musicPlayer.stopPlayback();
	
	// stop radion if it's playing
	if(isPlaying){
		try{
			radioSound.close();
			radioSound = null;
			radioChannel.stop();
		}catch(e:Error){}
	}
	
	// load new stream
	currentRadioURL = url;
	currentRadioTitle = currentRadio.text = title;
	isPlaying = true;
	playRadio.source = pauseImg;
	
	// play new stream
	radioSound = new Sound(new URLRequest(currentRadioURL));
	radioChannel = radioSound.play();
}

public function killRadio():void{
	if(isPlaying){
		try{
			radioSound.close();
			radioSound = null;
			radioChannel.stop();
		}catch(e:Error){}
		
		playRadio.source = playImg;
		currentRadio.text = "Radio is off";
		
		isPlaying = false;
	}
}