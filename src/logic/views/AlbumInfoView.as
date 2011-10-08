
import com.codezen.mse.MusicSearchEngine;
import com.codezen.util.CUtils;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.utils.ObjectUtil;

private var mse:MusicSearchEngine;

public function doWork():void{	
	mse = FlexGlobals.topLevelApplication.mse;
	
	FlexGlobals.topLevelApplication.musicPlayer.mp3sList = null;
	
	artistName.text = FlexGlobals.topLevelApplication.currentAlbum.artist.name; 
	albumName.text = FlexGlobals.topLevelApplication.currentAlbum.name;
	albumImage.source = FlexGlobals.topLevelApplication.currentAlbum.image;
	
	mse.addEventListener(Event.COMPLETE, onAlbumTracks);
	mse.getAlbumTracks(FlexGlobals.topLevelApplication.currentAlbum);
}

private function onAlbumTracks(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onAlbumTracks);
	
	FlexGlobals.topLevelApplication.currentAlbum.songs = mse.album.songs;
	songsList.dataProvider = new ArrayCollection(mse.album.songs);
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

