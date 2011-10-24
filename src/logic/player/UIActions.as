import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;

import spark.components.Group;

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
/**					UI STUFF					 **/
/******************************************************/
private function toggleFullMode():void{
	isFullMode = !isFullMode;
	if(isFullMode){
		// enable full mode
		//toggleFullBtn.source = normalImg;
		
		this.x = stage.stageWidth - this.width;
		var grp:Group = this;
		TweenLite.to(this, 0.5, {x:0, width: stage.stageWidth, onComplete:function():void{
			grp.percentWidth = 100;
		}});
		//TweenLite.to(FlexGlobals.topLevelApplication.nativeWindow, 0.5, {width:w});
	}else{
		// revert to normal
		//toggleFullBtn.source = fullImg;
		
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
	playQueue = [];
	songList.dataProvider = new ArrayCollection(playQueue);
}