import com.codezen.mse.playr.PlayrEvent;
import com.codezen.mse.playr.PlayrStates;
import com.codezen.util.CUtils;

import flash.events.ErrorEvent;
import flash.events.Event;

import mx.core.FlexGlobals;

import spark.utils.TextFlowUtil;

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
		
		var artist:String = CUtils.convertHTMLEntities(player.artist);
		var song:String = CUtils.convertHTMLEntities(player.title);
		
		nowPlayingText.textFlow = TextFlowUtil.importFromString("<span fontWeight='bold'>"+song+"</span>&nbsp;<span fontSize='12'> by "+artist+"</span>");
		
		FlexGlobals.topLevelApplication.setTrayTooltip( "Mielophone: "+artist+" - "+song );
		FlexGlobals.topLevelApplication.nativeWindow.title = "Mielophone: "+artist+" - "+song;
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
	
	// do stuff on 70% of track
	if( player.currentSeconds > (player.totalSeconds * 0.7) ){
		// scrobble track on 70%
		if(scrobbler != null && scrobbler.isInitialized && !trackScrobbled){
			scrobbler.doScrobble(player.artist, player.title, new Date().time.toString());
			trackScrobbled = true;
		}
		
		// search for next track url
		if(!prefetchedNext) prefetchNextSong();
		
		// post to facebook
		if(!fbSongPosted){
			fbSongPosted = true;
			FlexGlobals.topLevelApplication.postFbSong(player.artist, player.title);
		}
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
	
	var artist:String = CUtils.convertHTMLEntities(player.artist);
	var song:String = CUtils.convertHTMLEntities(player.title);
	
	nowPlayingText.textFlow = TextFlowUtil.importFromString("<span fontWeight='bold'>"+song+"</span>&nbsp;<span fontSize='12'> by "+artist+"</span>");
	
	FlexGlobals.topLevelApplication.setTrayTooltip( "Mielophone: "+artist+" - "+song );
	FlexGlobals.topLevelApplication.nativeWindow.title = "Mielophone: "+artist+" - "+song;
	
	// get cover
	mse.addEventListener(Event.COMPLETE, onTrackCover);
	mse.addEventListener(ErrorEvent.ERROR, onCoverError);
	mse.getTrackInfo(artist, song);
}

private function onTrackCover(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onTrackCover);
	
	if(mse.songInfo.album.image != null && mse.songInfo.album.image.length > 0){
		//albumCover.source = mse.songInfo.album.image;
	}else{
		//albumCover.source = nocoverImg;
	}
}

private function onCoverError(e:Event):void{
	mse.removeEventListener(ErrorEvent.ERROR, onCoverError);
	
	trace('album search error');
	
	//albumCover.source = nocoverImg;
}