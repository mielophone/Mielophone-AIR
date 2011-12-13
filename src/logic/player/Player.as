
import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.models.Album;
import com.codezen.mse.models.Artist;
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
import spark.utils.TextFlowUtil;

/******************************************************/
/**					INIT STUFF					 	**/
/******************************************************/
public function initPlayer():void{	
	playerRepeat = playerShuffle = false;
	isFullMode = false;
	prefetchedNext = false;
	fbSongPosted = false;
	
	nextRandomPos = -1;
	
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
	// playlist
	if( playerSettings.data.playlist != null ){
		playQueue = [];
		
		var s:Song;
		var o:Object;
		for each(o in playerSettings.data.playlist){
			s = new Song();
			s.duration = o.duration;
			s.durationText = o.durationText;
			s.name = o.name;
			s.number = o.number;
			s.artist = new Artist();
			s.artist.name = o.artist.name;
			s.artist.mbID = o.artist.mbID;
			
			playQueue.push(s);
		} 
		songList.dataProvider = new ArrayCollection(playQueue);
	}else{
		playQueue = [];
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

public function pausePlayback():void{
	player.pause();
}

public function resumePlayback():void{
	player.play();
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
	
	storePlaylist();
}

public function addSongToPlaylist(s:Song):void{
	playQueue.push(s);
	
	songList.dataProvider = new ArrayCollection(playQueue);
	
	storePlaylist();
}

public function getCurrentTrack():PlayrTrack{
	return player.playlist.getCurrentTrack();
}

/******************************************************/
/**					SEARCH AND PLAY				 	 **/
/******************************************************/
public function playSongByNum(num:int):void{
	playPos = num;
	// notify about index change
	this.dispatchEvent(new Event(Event.CHANGE));
	
	//albumCover.source = nocoverImg;
	nowPlayingText.text = "Searching for stream..";
	if(playQueue[playPos].track == null){
		nowSearching = true;
		mse.addEventListener(Event.COMPLETE, onSongLinks);
		mse.findMP3(playQueue[playPos] as Song);
	}else{
		playSong(playQueue[playPos].track);
	}
	//findSongAndPlay(playQueue[playPos] as Song);
}

public function findNextSong():void{
	trace('next song');
	if(nowSearching) return;
	if(playQueue == null || playQueue.length < 1) return;
	
	nowSearching = true;
	if( playerShuffle ){
		playPos = nextRandomPos == -1 ? Math.round( playQueue.length * Math.random() ) : nextRandomPos;
		nextRandomPos = -1;
	}else{
		playPos++;
	}
	
	// notify about index change
	this.dispatchEvent(new Event(Event.CHANGE));
	
	if(playPos < 0 || playPos >= playQueue.length){
		if(playerRepeat){
			playPos = 0;
			findSongAndPlay(playQueue[playPos] as Song);
		}else{
			nowSearching = false;
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
		nowSearching = false;
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
		
		//albumCover.source = nocoverImg;
		nowPlayingText.text = "Searching for stream..";
		
		if(song.track == null){
			nowSearching = true;
			mse.addEventListener(Event.COMPLETE, onSongLinks);
			mse.findMP3(song);
		}else{
			playSong(song.track);
		}
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
			storePlaylist();
			if(startPlay) findNextSong();
			break;
		
		case PLAYLIST_CLEAR:
			playQueue = [song];
			playPos = -1;
			songList.dataProvider = new ArrayCollection(playQueue);
			storePlaylist();
		case PLAYLIST_IGNORE:
		default:
			//albumCover.source = nocoverImg;
			nowPlayingText.text = "Searching for stream..";
			if(song.track == null){
				nowSearching = true;
				mse.addEventListener(Event.COMPLETE, onSongLinks);
				mse.findMP3(song);
			}else{
				playSong(song.track);
			}
			break;
	}
}

private function onSongLinks(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSongLinks);
	
	nowSearching = false;
	
	if( mse.mp3s.length == 0 ){
		trace('nothing :(');
		playQueue[playPos].number = -100;
		findNextSong();
		return;
	}
	
	playSong(mse.mp3s[0] as PlayrTrack);
}

private function playSong(song:PlayrTrack):void{
	nowSearching = false;
	
	// kill radio if it's playing
	FlexGlobals.topLevelApplication.radioView.killRadio();
	
	// create playlist for song
	var pl:PlaylistManager = new PlaylistManager();
	pl.addTrack(song);
	
	fbSongPosted = prefetchedNext = trackScrobbled = false;
	
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
			storePlaylist();
			if(startPlay) findNextSong();
			break;
		
		case PLAYLIST_CLEAR:
		case PLAYLIST_IGNORE:
			playQueue = FlexGlobals.topLevelApplication.currentAlbum.songs.concat();
			playPos = -1;
			
			songList.dataProvider = new ArrayCollection(playQueue);
			
			storePlaylist();
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
	var startPlay:Boolean = false;
	
	switch(playerBehavior)
	{
		case PLAYLIST_APPEND:
			if(playQueue == null || playQueue.length < 1){
				playPos = -1;
				startPlay = true;
			}
			playQueue = playQueue.concat(ac);
			break;
		
		case PLAYLIST_CLEAR:
		case PLAYLIST_IGNORE:
			playQueue = ac.concat();
			playPos = -1;
			startPlay = true;
			break;
	}
	
	songList.dataProvider = new ArrayCollection(playQueue);
	
	storePlaylist();
	
	if(startPlay) findNextSong();
}