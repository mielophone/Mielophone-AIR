
import com.codezen.mse.models.Song;
import com.codezen.mse.playr.PlayrTrack;

import flash.events.Event;

import mx.utils.ObjectUtil;

private var prefetchNum:int;
private var prefetchSong:Song;
private var prefetchedNext:Boolean;

private function prefetchNextSong():void{
	if(nowSearching) return;
	if(prefetchedNext) return;
	
	if(playerShuffle){
		nextRandomPos = prefetchNum = Math.round( playQueue.length * Math.random() );
	}else{
		prefetchNum = playPos+1;
	}
	prefetchSong = playQueue[prefetchNum] as Song;
	
	if(prefetchSong.track == null){
		trace('searching for next song link');
		trace(ObjectUtil.toString(prefetchSong));
		nowSearching = true;
		mse.addEventListener(Event.COMPLETE, onSongLinkPrefetch);
		mse.findMP3(prefetchSong);
	}
}

private function onSongLinkPrefetch(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSongLinkPrefetch);
	
	nowSearching = false;
	
	if( mse.mp3s.length == 0 ){
		trace('nothing for next song :(');
		playQueue[prefetchNum].number = -100;
		//findNextSong();
		return;
	}
	
	prefetchSong.track = mse.mp3s[0] as PlayrTrack;
	
	prefetchedNext = true;
	
	trace('found next song link');
	trace(ObjectUtil.toString(prefetchSong.track));
}