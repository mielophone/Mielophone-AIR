
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
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;

/******************************************************/
/**						IMAGES						 **/
/******************************************************/
[Bindable]
[Embed(source="/assets/player/play.png")]
private var playImg:Class;

[Bindable]
[Embed(source="/assets/player/pause.png")]
private var pauseImg:Class;

[Bindable]
[Embed(source="/assets/images/nocover.png")]
private var nocoverImg:Class;

/******************************************************/
/**						VARS						 **/
/******************************************************/
private var hideTimer:Timer;

private var mse:MusicSearchEngine;
// TODO: move this to MSE as a state
private var nowSearching:Boolean = false;

private var player:Playr;
private var playQueue:Array;
private var playPos:int;

public var mp3sList:Array;

/******************************************************/
/**					INIT STUFF					 	**/
/******************************************************/
public function initPlayer():void{
	hideTimer = new Timer(500, 1);
	hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onHideTimer);
	
	mse = FlexGlobals.topLevelApplication.mse;
	
	player = new Playr();
	
	player.addEventListener(PlayrEvent.PLAYRSTATE_CHANGED, onPlayerState);
	player.addEventListener(PlayrEvent.TRACK_PROGRESS, onProgress);
	player.addEventListener(PlayrEvent.STREAM_PROGRESS, onStreamProgress);
	player.addEventListener(PlayrEvent.SONGINFO, onSong);
	player.addEventListener(PlayrEvent.TRACK_COMPLETE, onTrackEnd);
	
	timeSlider.slider.addEventListener(FlexEvent.CHANGE_END, onSeek);
	timeSlider.slider.dataTipFormatFunction = timeDataTip;
}

/**
 * Data tip for time slider 
 * @param val
 * @return 
 * 
 */
private function timeDataTip(val:String):String{
	var duration:Number = Number(val);
	
	return CUtils.secondsToString(duration);
}

/******************************************************/
/**					PLAYER EVENTS					 **/
/******************************************************/
private function onSeek(e:Event):void{
	var seekTime:Number = timeSlider.slider.value*1000;
	player.scrobbleTo(seekTime);
}


private function onTrackEnd(e:PlayrEvent):void{
	timeMax.text = "--:--";
	timeCurrent.text = "--:--";
	FlexGlobals.topLevelApplication.nativeWindow.title = "Mielophone";
	findNextSong();
}

private function onPlayerState(e:PlayrEvent):void{
	switch(e.playrState){
		case PlayrStates.PLAYING:
			playBtn.source = pauseImg;
			break;
		case PlayrStates.STOPPED:
		case PlayrStates.WAITING:
			timeMax.text = "--:--";
			timeCurrent.text = "--:--";
			FlexGlobals.topLevelApplication.nativeWindow.title = "Mielophone";
		case PlayrStates.PAUSED:
			playBtn.source = playImg;
			break;
	}
}

private function onProgress(e:PlayrEvent):void{
	if(timeSlider.maximum != player.totalSeconds){
		timeSlider.maximum = player.totalSeconds;
		timeMax.text = player.totalTime;
		artistName.text = CUtils.convertHTMLEntities(player.artist); 
		songName.text = CUtils.convertHTMLEntities(player.title);
		FlexGlobals.topLevelApplication.nativeWindow.title = "Mielophone: "+artistName.text+" - "+songName.text;
	}
	timeSlider.position = player.currentSeconds;
	
	// workaround for end event not dispatching
	if(player.currentSeconds >= player.totalSeconds){
		player.scrobbleTo(0);
		player.stop();
		onTrackEnd(null);
		return;
	}
	
	timeCurrent.text = player.currentTime;
}

private function onStreamProgress(e:PlayrEvent):void{
	timeSlider.progress = e.progress;
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
	
	FlexGlobals.topLevelApplication.nativeWindow.title = "Mielophone: "+artistName.text+" - "+songName.text;
}

/******************************************************/
/**				PLAYER BUTTONS HANDLERS			 	 **/
/******************************************************/
private function playBtn_clickHandler(event:Event):void{
	player.togglePlayPause();
}

private function next_btn_clickHandler(event:MouseEvent):void{
	findNextSong();
}

private function prev_btn_clickHandler(event:MouseEvent):void{
	findPrevSong();
}

private function onVolumeSlider(e:Event):void{
	player.volume = volumeSlider.value/100;
}

/******************************************************/
/**					SEARCH AND PLAY				 	 **/
/******************************************************/
public function findNextSong():void{
	trace('next song');
	if(nowSearching) return;
	if(playQueue == null) return;
	
	playPos++;
	if(playPos < 0 || playPos >= playQueue.length) playPos = 0;
	findSongAndPlay(playQueue[playPos] as Song);
}

public function findPrevSong():void{
	trace('prev song');
	if(nowSearching) return;
	if(playQueue == null) return;
	
	playPos--;
	if(playPos < 0) playPos = playQueue.length-1;
	nowSearching = true;
	findSongAndPlay(playQueue[playPos] as Song);
}

public function findSongAndPlay(song:Song):void{
	if(mp3sList != null){
		nowSearching = false;
		playSong(mp3sList[song.number] as PlayrTrack);
	}else{
		artistName.text = "Searching for stream..";
		songName.text = "";
		nowSearching = true;
		mse.addEventListener(Event.COMPLETE, onSongLinks);
		mse.findMP3(song);
	}
}

private function onSongLinks(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSongLinks);
	
	nowSearching = false;
	
	if( mse.mp3s.length == 0 ){
		trace('nothing :(');
		findNextSong();
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

/******************************************************/
/**					ALBUM PLAYBACK					 **/
/******************************************************/
public function playCurrentAlbum():void{
	playQueue = FlexGlobals.topLevelApplication.currentAlbum.songs.concat();
	playPos = -1;
	
	songList.dataProvider = new ArrayCollection(playQueue);
	
	findNextSong();
}

/******************************************************/
/**					UI HIDING STUFF					 **/
/******************************************************/
private function onHideTimer(e:Event):void{
	TweenLite.to(this, 0.4, {right:-300});
}

private function onMouseOut(e:MouseEvent):void{
	hideTimer.start();
}

private function onMouseMove(e:MouseEvent):void{
	hideTimer.stop();
	hideTimer.reset();
}