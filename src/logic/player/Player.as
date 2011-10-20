
import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.models.Album;
import com.codezen.mse.models.Song;
import com.codezen.mse.playr.PlaylistManager;
import com.codezen.mse.playr.Playr;
import com.codezen.mse.playr.PlayrEvent;
import com.codezen.mse.playr.PlayrStates;
import com.codezen.mse.playr.PlayrTrack;
import com.codezen.mse.services.LastFM;
import com.codezen.mse.services.LastfmScrobbler;
import com.codezen.mse.services.MusicBrainz;
import com.codezen.util.CUtils;
import com.greensock.TweenLite;

import flash.errors.EOFError;
import flash.errors.IOError;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.net.SharedObject;
import flash.net.URLRequest;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.utils.ObjectUtil;

import spark.components.Group;

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

[Bindable]
[Embed(source="/assets/player/playernormal.png")]
private var normalImg:Class;

[Bindable]
[Embed(source="/assets/player/playerfull.png")]
private var fullImg:Class;

/******************************************************/
/**					CONSTANTS						 **/
/******************************************************/

public static const PLAYLIST_IGNORE:String = "IgnorePlaylist";
public static const PLAYLIST_CLEAR:String = "ClearPlaylist";
public static const PLAYLIST_APPEND:String = "AppendPlaylist";

/******************************************************/
/**						VARS						 **/
/******************************************************/
// UI Stuff
private var hideTimer:Timer;
private var isFullMode:Boolean;

// MSE
private var mse:MusicSearchEngine;
// TODO: move this to MSE as a state
private var nowSearching:Boolean = false;

// Player stuff
private var playerSettings:SharedObject;
private var playerBehavior:String;
private var player:Playr;
private var playQueue:Array;
private var playerVolume:int;
private var playerRepeat:Boolean;
private var playerShuffle:Boolean;
public var playPos:int;

// tweaks
private var lastPositionMilliseconds:Number;

// Scrobbler 
private var scrobbler:LastfmScrobbler;
private var scrobblerSettings:SharedObject;
private var scrobbleName:String;
private var scrobblePass:String;
private var trackScrobbled:Boolean;

/******************************************************/
/**					INIT STUFF					 	**/
/******************************************************/
public function initPlayer():void{
	hideTimer = new Timer(500, 1);
	hideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onHideTimer);
	
	playerRepeat = playerShuffle = false;
	isFullMode = false;
	playQueue = [];
	
	mse = FlexGlobals.topLevelApplication.mse;
	
	player = new Playr();
	// add events
	player.addEventListener(PlayrEvent.PLAYRSTATE_CHANGED, onPlayerState);
	player.addEventListener(PlayrEvent.TRACK_PROGRESS, onProgress);
	player.addEventListener(PlayrEvent.STREAM_PROGRESS, onStreamProgress);
	player.addEventListener(PlayrEvent.SONGINFO, onSong);
	player.addEventListener(PlayrEvent.TRACK_COMPLETE, onTrackEnd);
	// load player settings
	playerSettings = SharedObject.getLocal("mielophone.player");
	// buffer
	if( playerSettings.data.buffer != null ){
		player.buffer = playerSettings.data.buffer;
		FlexGlobals.topLevelApplication.settingsView.bufferingSlider.value = playerSettings.data.buffer / 1000; 
	}
	// volume
	if( playerSettings.data.volume != null ){
		playerVolume = playerSettings.data.volume;
		player.volume = playerVolume/100;
		volumeSlider.value = playerVolume;
	}else{
		playerVolume = 100;
	}
	// behavior
	if( playerSettings.data.behavior != null ){
		playerBehavior = playerSettings.data.behavior;
		FlexGlobals.topLevelApplication.settingsView.playlistBehavior.selectedIndex = playerSettings.data.behaviorIndex;
	}else{
		playerBehavior = PLAYLIST_IGNORE;
	}
	
	timeSlider.slider.addEventListener(FlexEvent.CHANGE_END, onSeek);
	timeSlider.slider.dataTipFormatFunction = timeDataTip;
	
	// load scrobbling settings
	scrobblerSettings = SharedObject.getLocal("mielophone.scrobbling");
	if( scrobblerSettings.data.username != null ){
		scrobbleName = scrobblerSettings.data.username;
		scrobblePass = scrobblerSettings.data.pass;
		FlexGlobals.topLevelApplication.settingsView.lastfmLogin.text = scrobbleName;
		FlexGlobals.topLevelApplication.settingsView.lastfmPass.text = scrobblePass;
		
		// scrobbling
		initScrobbler();
	}
}

public function initScrobbler():void{	
	if(scrobbleName.length > 1 && scrobblePass.length > 1){
		trace("scrobble init");
		scrobbler = new LastfmScrobbler("0b18095c48d2bb8bf4acbab629bcc30e", "536549b8e66a766fe3de7d61a0fa7390");
		scrobbler.addEventListener(ErrorEvent.ERROR, function():void{
			Alert.show("Some error in scrobbling class! Wrong login/pass?", "Scrobbling error!");
		});
		scrobbler.addEventListener(Event.INIT, function(e:Event):void{
			trace('scrobble inited');
		});
		scrobbler.auth(scrobbleName, scrobblePass);
	}
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
/**					PLAYER FUNCS					 **/
/******************************************************/

public function setBuffer(b:int):void{
	player.buffer = b;
	playerSettings.data.buffer = b;
	playerSettings.flush();
}

public function setPlaylistBehavior(behavior:String, index:int):void{
	playerBehavior = behavior;
	playerSettings.data.behavior = behavior;
	playerSettings.data.behaviorIndex = index;
	playerSettings.flush();
}

public function setScrobblingAuth(login:String, pass:String):void{
	scrobblerSettings.data.username = scrobbleName = login;
	scrobblerSettings.data.pass = scrobblePass = pass;
	scrobblerSettings.flush();
	
	if(login.length > 0 && pass.length > 0) initScrobbler();
}

public function togglePlayPause():void{
	player.togglePlayPause();
}

public function stopPlayback():void{
	player.stop();
}

public function playNext():void{
	findNextSong();
}

public function deleteSongFromPlaylist(index:int):void{
	playQueue.splice(index,1);
	if(playPos == index) playPos = -1;
	
	songList.dataProvider = new ArrayCollection(playQueue);
}

public function addSongToPlaylist(s:Song):void{
	playQueue.push(s);
	
	songList.dataProvider = new ArrayCollection(playQueue);
}

public function getCurrentTrack():PlayrTrack{
	return player.playlist.getCurrentTrack();
}

/******************************************************/
/**					PLAYER EVENTS					 **/
/******************************************************/
private function onSeek(e:Event):void{
	var seekTime:Number = timeSlider.slider.value*1000;
	player.scrobbleTo(seekTime);
}


private function onTrackEnd(e:PlayrEvent):void{
	timeMax.text = "";
	timeCurrent.text = "";
	
	FlexGlobals.topLevelApplication.setTrayTooltip();
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
			timeMax.text = "";
			timeCurrent.text = "";
			
			FlexGlobals.topLevelApplication.setTrayTooltip();
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
		FlexGlobals.topLevelApplication.setTrayTooltip( "Mielophone: "+CUtils.convertHTMLEntities(artistName.text)+" - "+CUtils.convertHTMLEntities(songName.text) );
		FlexGlobals.topLevelApplication.nativeWindow.title = "Mielophone: "+CUtils.convertHTMLEntities(artistName.text)+" - "+CUtils.convertHTMLEntities(songName.text);
	}
	
	// check if playback is stuck
	if(lastPositionMilliseconds == player.currentMiliseconds && player.currentMiliseconds != 0 && player.playrState != PlayrStates.BUFFERING){
		player.scrobbleTo(0);
		player.stop();
		onTrackEnd(null);
		return;
	}
	
	lastPositionMilliseconds = player.currentMiliseconds;
	timeSlider.position = player.currentSeconds;
	
	// scrobble track on 70%
	if( scrobbler != null && scrobbler.isInitialized && !trackScrobbled && player.currentSeconds > (player.totalSeconds * 0.7) ){
		scrobbler.doScrobble(artistName.text, songName.text, new Date().time.toString());
		trackScrobbled = true;
	}
	
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
	timeSlider.maximum = player.totalSeconds;
	timeMax.text = player.totalTime;
	artistName.text = CUtils.convertHTMLEntities(player.artist); 
	songName.text = CUtils.convertHTMLEntities(player.title);
	
	FlexGlobals.topLevelApplication.setTrayTooltip( "Mielophone: "+CUtils.convertHTMLEntities(artistName.text)+" - "+CUtils.convertHTMLEntities(songName.text) );
	FlexGlobals.topLevelApplication.nativeWindow.title = "Mielophone: "+CUtils.convertHTMLEntities(artistName.text)+" - "+CUtils.convertHTMLEntities(songName.text);
	
	// get cover
	mse.addEventListener(Event.COMPLETE, onTrackCover);
	mse.addEventListener(ErrorEvent.ERROR, onCoverError);
	mse.getTrackInfo(artistName.text, songName.text);
}

private function onTrackCover(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onTrackCover);
	
	if(mse.songInfo.album.image != null && mse.songInfo.album.image.length > 0){
		albumCover.source = mse.songInfo.album.image;
	}else{
		albumCover.source = nocoverImg;
	}
}

private function onCoverError(e:Event):void{
	mse.removeEventListener(ErrorEvent.ERROR, onCoverError);
	
	trace('album search error');
	
	albumCover.source = nocoverImg;
}
/******************************************************/
/**				PLAYER BUTTONS HANDLERS			 	 **/
/******************************************************/
private function playBtn_clickHandler(event:Event):void{
	togglePlayPause();
}

private function next_btn_clickHandler(event:MouseEvent):void{
	findNextSong();
}

private function prev_btn_clickHandler(event:MouseEvent):void{
	findPrevSong();
}

private function onVolumeSlider(e:Event):void{
	playerVolume = volumeSlider.value;
	
	playerSettings.data.volume = playerVolume;
	playerSettings.flush();
	
	player.volume = volumeSlider.value/100;
}

/******************************************************/
/**					SEARCH AND PLAY				 	 **/
/******************************************************/
public function playSongByNum(num:int):void{
	playPos = num;
	// notify about index change
	this.dispatchEvent(new Event(Event.CHANGE));
	
	albumCover.source = nocoverImg;
	artistName.text = "Searching for stream..";
	songName.text = "";
	nowSearching = true;
	mse.addEventListener(Event.COMPLETE, onSongLinks);
	mse.findMP3(playQueue[playPos] as Song);
	//findSongAndPlay(playQueue[playPos] as Song);
}

public function findNextSong():void{
	trace('next song');
	if(nowSearching) return;
	if(playQueue == null || playQueue.length < 1) return;
	
	nowSearching = true;
	if( playerShuffle ){
		playPos = Math.round( playQueue.length * Math.random() );
	}else{
		playPos++;
	}
	
	// notify about index change
	this.dispatchEvent(new Event(Event.CHANGE));
	
	if(playPos < 0 || playPos >= playQueue.length){
		if(playerRepeat){
			playPos = 0;
			findSongAndPlay(playQueue[playPos] as Song);
		}
	}else{
		findSongAndPlay(playQueue[playPos] as Song);
	}
}

public function findPrevSong():void{
	trace('prev song');
	if(nowSearching) return;
	if(playQueue == null || playQueue.length < 1) return;
	
	nowSearching = true;
	
	if( playerShuffle ){
		playPos = Math.round( playQueue.length * Math.random() );
	}else{
		playPos--;
	}
	
	// notify about index change
	this.dispatchEvent(new Event(Event.CHANGE));
	
	if(playPos < 0){
		playPos = -1;
	}else{
		findSongAndPlay(playQueue[playPos] as Song);
	}
}

public function findSongAndPlay(song:Song):void{	
	// check is song is already in queue
	var i:int, inqueue:Boolean;
	for(i = 0; i < playQueue.length; i++){
		if(playQueue[i] == song){
			trace('match');
			inqueue = true;
			break;
		}
	}
	// if song there, just play it
	if(inqueue){ 
		playPos = i;
		
		// notify about index change
		this.dispatchEvent(new Event(Event.CHANGE));
		
		albumCover.source = nocoverImg;
		artistName.text = "Searching for stream..";
		songName.text = "";
		
		nowSearching = true;
		
		mse.addEventListener(Event.COMPLETE, onSongLinks);
		mse.findMP3(song);
		return;
	}
	
	switch(playerBehavior)
	{
		case PLAYLIST_APPEND:
			var startPlay:Boolean;
			if(playQueue == null || playQueue.length < 1){
				playPos = -1;
				startPlay = true;
			}
			playQueue.push(song);
			songList.dataProvider = new ArrayCollection(playQueue);
			if(startPlay) findNextSong();
			break;
		
		case PLAYLIST_CLEAR:
			playQueue = [song];
			playPos = -1;
			songList.dataProvider = new ArrayCollection(playQueue);
		case PLAYLIST_IGNORE:
		default:
			albumCover.source = nocoverImg;
			artistName.text = "Searching for stream..";
			songName.text = "";
			nowSearching = true;
			mse.addEventListener(Event.COMPLETE, onSongLinks);
			mse.findMP3(song);
			break;
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
	// kill radio if it's playing
	FlexGlobals.topLevelApplication.radioView.killRadio();
	
	// create playlist for song
	var pl:PlaylistManager = new PlaylistManager();
	pl.addTrack(song);
	
	trackScrobbled = false;
	
	player.stop();
	player.playlist = pl;
	player.play();
	player.volume = playerVolume/100;
}

/******************************************************/
/**					ALBUM PLAYBACK					 **/
/******************************************************/
public function playCurrentAlbum():void{
	var startPlay:Boolean;
	
	switch(playerBehavior)
	{
		case PLAYLIST_APPEND:
			if(playQueue == null || playQueue.length < 1){
				playPos = -1;
				startPlay = true;
			}
			playQueue = playQueue.concat(FlexGlobals.topLevelApplication.currentAlbum.songs);
			songList.dataProvider = new ArrayCollection(playQueue);
			if(startPlay) findNextSong();
			break;
		
		case PLAYLIST_CLEAR:
		case PLAYLIST_IGNORE:
			playQueue = FlexGlobals.topLevelApplication.currentAlbum.songs.concat();
			playPos = -1;
			
			songList.dataProvider = new ArrayCollection(playQueue);
			
			findNextSong();
			break;
	}
}

public function playAlbum(album:Album):void{
	FlexGlobals.topLevelApplication.currentAlbum = album;
	
	mse.addEventListener(Event.COMPLETE, onAlbumTracks);
	mse.getAlbumTracks(album);
}

private function onAlbumTracks(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onAlbumTracks);
	
	FlexGlobals.topLevelApplication.currentAlbum.songs = mse.album.songs;
	
	playCurrentAlbum();
}

public function setQueue(ac:Array):void{
	playQueue = ac.concat();
	playPos = -1;
	
	songList.dataProvider = new ArrayCollection(playQueue);
}

/******************************************************/
/**					UI STUFF					 **/
/******************************************************/
private function onHideTimer(e:Event):void{
	if( !isFullMode )
		TweenLite.to(this, 0.4, {right:-300});
}

private function onMouseOut(e:MouseEvent):void{
	hideTimer.start();
}

private function onMouseMove(e:MouseEvent):void{
	hideTimer.stop();
	hideTimer.reset();
}

private function toggleFullMode():void{
	isFullMode = !isFullMode;
	if(isFullMode){
		hideTimer.stop();
		hideTimer.reset();
		
		// enable full mode
		toggleFullBtn.source = normalImg;
		
		this.x = stage.stageWidth - this.width;
		var grp:Group = this;
		TweenLite.to(this, 0.5, {x:0, width: stage.stageWidth, onComplete:function():void{
			grp.percentWidth = 100;
		}});
		//TweenLite.to(FlexGlobals.topLevelApplication.nativeWindow, 0.5, {width:w});
	}else{
		// revert to normal
		toggleFullBtn.source = fullImg;
		
		this.x = 0;
		this.right = 0;
		TweenLite.to(this, 0.5, {width:300});
	}
}

private function toggleRepeat():void{
	playerRepeat = !playerRepeat;
	
	if(playerRepeat){
		repeatGlow.alpha = 1;
	}else{
		repeatGlow.alpha = 0;
	}
}

private function toggleShuffle():void{
	playerShuffle = !playerShuffle;
	
	if(playerShuffle){
		shuffleGlow.alpha = 1;
	}else{
		shuffleGlow.alpha = 0;
	}
}

private function clearPlaylist():void{
	setQueue([]);	
}