
import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.models.Artist;
import com.codezen.mse.models.Song;
import com.codezen.mse.playr.PlayrTrack;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mielophone.ui.views.SongSearchView;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;

public function doWork():void{
	FlexGlobals.topLevelApplication.musicPlayer.mp3sList = null;
	
	getTopSongs();
}

private function getTopSongs():void{
	mse = FlexGlobals.topLevelApplication.mse;
	mse.addEventListener(Event.COMPLETE, onSongs);
	mse.getTopTracks();
}

private function onSongs(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSongs);
	
	songList.dataProvider = new ArrayCollection(mse.songs);
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onMouseMove(e:MouseEvent):void{
	if( e.stageY < 32 ){
		TweenLite.to(searchInput, 0.3, {height:32});
		//searchInput.height = 26;
	}else{
		if( searchInput.text.length == 0 ){
			TweenLite.to(searchInput, 0.3, {height:0});
		}
		//searchInput.height = 0;
	}
}

private function onSearchKeyUp(e:KeyboardEvent):void{
	if(e.keyCode == Keyboard.ENTER && searchInput.text.length > 1){
		mse.addEventListener(Event.COMPLETE, onSearch);
		mse.findMP3byText(searchInput.text);
		
		FlexGlobals.topLevelApplication.loadingOn();
		
		searchInput.text = '';
	}
}

private function onSearch(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSearch);
	
	FlexGlobals.topLevelApplication.loadingOff();
	
	FlexGlobals.topLevelApplication.musicPlayer.mp3sList = mse.mp3s;
	var _songs:ArrayCollection = new ArrayCollection();
	
	var pl:PlayrTrack;
	var song:Song;
	var num:int = 0;
	for each(pl in mse.mp3s){
		song = new Song();
		song.name = pl.title;
		song.artist = new Artist();
		song.artist.name = pl.artist;
		song.duration = pl.totalSeconds;
		song.durationText = pl.totalTime;
		song.number = num++;
		_songs.addItem(song);
	}
	
	songList.dataProvider = _songs;
}