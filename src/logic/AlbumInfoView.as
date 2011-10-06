
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
	
	albumName.text = FlexGlobals.topLevelApplication.currentAlbum.artist.name + " - " + 
		FlexGlobals.topLevelApplication.currentAlbum.name;
	albumImage.source = FlexGlobals.topLevelApplication.currentAlbum.image;
	
	mse.addEventListener(Event.COMPLETE, onAlbumTracks);
	mse.getAlbumTracks(FlexGlobals.topLevelApplication.currentAlbum);
	trace('start albums work');
}

private function onAlbumTracks(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onAlbumTracks);
	
	trace('got end from mse');
	trace( ObjectUtil.toString(mse.album.songs) );
	
	FlexGlobals.topLevelApplication.currentAlbum.songs = mse.album.songs;
	songsList.dataProvider = new ArrayCollection(mse.album.songs);
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

