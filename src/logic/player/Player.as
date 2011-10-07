
import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.models.Song;
import com.codezen.mse.playr.PlaylistManager;
import com.codezen.mse.playr.Playr;
import com.codezen.mse.playr.PlayrEvent;
import com.codezen.mse.playr.PlayrStates;
import com.codezen.mse.playr.PlayrTrack;
import com.codezen.mse.services.LastFM;
import com.codezen.mse.services.MusicBrainz;
import com.codezen.util.CUtils;
import com.greensock.TweenLite;

import flash.events.Event;

import mx.core.FlexGlobals;

[Bindable]
[Embed(source="/assets/player/play.png")]
private var playImg:Class;

[Bindable]
[Embed(source="/assets/player/pause.png")]
private var pauseImg:Class;

[Bindable]
[Embed(source="/assets/images/nocover.png")]
private var nocoverImg:Class;

private var mse:MusicSearchEngine;

private var player:Playr;
private var playQueue:Array;
private var playPos:int;


public function initPlayer():void{
	mse = FlexGlobals.topLevelApplication.mse;
	
	player = new Playr();
	
	player.addEventListener(PlayrEvent.PLAYRSTATE_CHANGED, onPlayerState);
	player.addEventListener(PlayrEvent.TRACK_PROGRESS, onProgress);
	player.addEventListener(PlayrEvent.SONGINFO, onSong);
	player.addEventListener(PlayrEvent.TRACK_COMPLETE, onTrackEnd);
}

private function onTrackEnd(e:PlayrEvent):void{
	//nowplay_text.text = "Searching for stream..";
	//FlexGlobals.topLevelApplication.findNextSong();
}

private function onPlayerState(e:PlayrEvent):void{
	switch(e.playrState){
		case PlayrStates.PLAYING:
			playBtn.source = pauseImg;
			break;
		case PlayrStates.STOPPED:
		case PlayrStates.PAUSED:
		case PlayrStates.WAITING:
			playBtn.source = playImg;
			timeMax.text = "--:--";
			timeCurrent.text = "--:--";
			break;
	}
}

private function onProgress(e:PlayrEvent):void{
	if(timeSlider.maximum != player.totalSeconds){
		timeSlider.maximum = player.totalSeconds;
		timeMax.text = player.totalTime;
		artistName.text = CUtils.convertHTMLEntities(player.artist); 
		songName.text = CUtils.convertHTMLEntities(player.title);
	}
	timeSlider.position = player.currentSeconds;
	
	if(player.currentSeconds >= player.totalSeconds){
		player.scrobbleTo(0);
		player.stop();
		onTrackEnd(null);
		return;
	}
	
	timeCurrent.text = player.currentTime;
}

private function onSong(e:PlayrEvent):void{	
	if(FlexGlobals.topLevelApplication.currentAlbum != null){
		albumCover.source = FlexGlobals.topLevelApplication.currentAlbum.image; 
	}else{
		albumCover.source = nocoverImg;
		// TODO: SEARCH FOR TRACK COVER
	}
	
	timeSlider.maximum = player.totalSeconds;
	timeMax.text = player.totalTime;
	artistName.text = CUtils.convertHTMLEntities(player.artist); 
	songName.text = CUtils.convertHTMLEntities(player.title);
}

// ------------------			
private function secToTime(sec:Number):String{
	var duration:String = '';
	var secs:int = sec;
	var mins:int = Math.floor(secs/60);
	secs = secs - mins*60;
	if( secs < 10 ){
		duration = mins+":0"+secs;
	}else{
		duration = mins+":"+secs;
	}
	return duration;
}

// -----------------------------------

private function playBtn_clickHandler(event:Event):void{
	player.togglePlayPause();
}

/*private function next_btn_clickHandler(event:MouseEvent):void{
	findNextSong();
}

private function prev_btn_clickHandler(event:MouseEvent):void{
	findPrevSong();
}*/

// -----------------------------

public function findSongAndPlay(song:Song):void{
	artistName.text = "Searching for stream..";
	songName.text = "";
	mse.addEventListener(Event.COMPLETE, onSongLinks);
	mse.findMP3(song);
}

private function onSongLinks(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSongLinks);
	
	if( mse.mp3s.length == 0 ){
		trace('nothing :(');
		//findNextSong();
		return;
	}
	
	playSong(mse.mp3s[0] as PlayrTrack);
}

private function playSong(song:PlayrTrack):void{
	var pl:PlaylistManager = new PlaylistManager();
	pl.addTrack(song);
	
	player.stop();
	player.playlist = pl;
	player.play();
}

private function onMouseOut(e:Event):void{
	TweenLite.to(this, 0.4, {right:-300});
}