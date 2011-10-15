
import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.models.Artist;
import com.codezen.mse.models.Song;
import com.codezen.mse.playr.PlayrTrack;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mielophone.ui.views.search.SongSearchView;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;
private var topSongs:ArrayCollection;

public function doWork():void{
	getTopSongs();
}

private function getTopSongs():void{
	if(mse != null && songList.dataProvider != null){
		this.dispatchEvent(new Event(Event.COMPLETE));
		return;
	}
	
	mse = FlexGlobals.topLevelApplication.mse;
	mse.addEventListener(Event.COMPLETE, onSongs);
	mse.getTopTracks();
}

private function onSongs(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSongs);
	
	//FlexGlobals.topLevelApplication.musicPlayer.setQueue(mse.songs);
	topSongs = new ArrayCollection(mse.songs);
	songList.dataProvider = topSongs;
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onSearchKeyUp(e:KeyboardEvent):void{
	if(e.keyCode == Keyboard.ENTER && searchInput.text.length > 1){
		mse.addEventListener(Event.COMPLETE, onSearch);
		mse.findMP3byText(searchInput.text);
		
		FlexGlobals.topLevelApplication.loadingOn();
		
		searchInput.text = '';
	}else if(e.keyCode == Keyboard.ESCAPE && searchInput.text.length < 1){
		songList.dataProvider = topSongs;
	}
}

private function onSearch(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSearch);
	
	FlexGlobals.topLevelApplication.loadingOff();
	
	var _songs:Array = [];
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
		_songs.push(song);
	}
	
	//FlexGlobals.topLevelApplication.musicPlayer.setQueue(_songs);
	songList.dataProvider = new ArrayCollection( _songs );
}