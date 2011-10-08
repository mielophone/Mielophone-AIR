import com.codezen.skins.scroll.SmallScroll;
import com.codezen.skins.scroll.SmallVScrollThumb;
import com.codezen.skins.scroll.SmallVScrollTrack;
import com.greensock.TweenLite;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Mouse;
import flash.utils.Timer;

import mx.messaging.messages.ErrorMessage;
import mx.utils.ObjectUtil;

import spark.components.Group;

/******************************************************/
/**						VARS						 **/
/******************************************************/
// back button activator
private var isBackActive:Boolean = false;
// display timers
// back button 
private var backTimer:Timer;
// player
private var playerTimer:Timer;
// current view
private var currentView:String;
// views array
private var viewHistory:Array;

/******************************************************/
/**					INITIALIZATION					 **/
/******************************************************/
private function initViewHelpers():void{
	viewHistory = [];
	currentView = "homeView";
	
	backTimer = new Timer(500, 1);
	backTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onBackTimer);
	
	playerTimer = new Timer(1000, 1);
	playerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onPlayerTimer);
}

/******************************************************/
/**					PLAYER HANDLING			 		 **/
/******************************************************/

private function onPlayerTimer(e:Event):void{
	TweenLite.to(musicPlayer, 0.3, {right:0});	
}

/******************************************************/
/**				BACK BUTTON HANDLING			 	 **/
/******************************************************/
private function onAppMouseMove(e:MouseEvent):void{	
	if( e.stageX < 20 ){
		if( isBackActive )	backTimer.start();
	}else if( e.stageX > this.stage.stageWidth - 25 ){
		// detect if user is using scroll
		if(e.target.id == "track" || e.target.id == "thumb"){
			playerTimer.stop();
			playerTimer.reset();
		}else{
			playerTimer.start();
		}
	}else{
		// player stop
		playerTimer.stop();
		playerTimer.reset();
		
		// back stop
		if( !isBackActive ) return;
		backTimer.stop();
		backTimer.reset();
		if(backButton.left != -36){
			TweenLite.to(backButton, 0.3, {left:-36});
		}
	}
}

private function onBackTimer(e:Event):void{
	TweenLite.to(backButton, 0.3, {left:0});	
}

private function onBackButtonClick(e:Event):void{
	if( viewHistory.length == 0 ) return;
	
	// new view var
	var newView:String;
	
	// if home button pressed - go home
	if( e.target.parent.id == "homeBtn" ){
		// pop and hide all old views
		while(viewHistory.length > 1){
			newView = viewHistory.pop();
			this[newView].visible = false;
		}
	}
	
	// get new view string
	newView = viewHistory.pop();
	// if new is home 
	if( newView == "homeView" ){
		isBackActive = false;
	}
	
	// hide button
	backTimer.stop();
	backTimer.reset();
	TweenLite.to(backButton, 0.3, {left:-36});
	
	// get current view
	var view:Group = this[currentView];
	// reset size and position to absolute 
	view.horizontalCenter = view.verticalCenter = 0;
	view.height = stage.stageHeight; 
	view.width = nativeWindow.width;
	
	// animate move-out
	TweenLite.to(view, 0.3, {width:nativeWindow.width-100, height:stage.height-100, onComplete:function():void{
		TweenLite.to(view, 0.5, {horizontalCenter:nativeWindow.width, onComplete:function():void{
			view.visible = false;
		}});
	}});
	
	currentView = newView;
}

/******************************************************/
/**					VIEW CHANGING					 **/
/******************************************************/

public function changeView(view:*):void{
	// save last view
	viewHistory.push(currentView);
	
	// show loader
	loadingOn();
	
	// do view work
	view.addEventListener(Event.COMPLETE, onViewWork);
	view.addEventListener(ErrorEvent.ERROR, onViewError);
	view.doWork();
}

private function onViewError(e:ErrorEvent):void{
	e.target.removeEventListener(Event.COMPLETE, onViewWork);
	e.target.removeEventListener(ErrorEvent.ERROR, onViewError);
	
	loadingOff();
}

private function onViewWork(e:Event):void{
	e.target.removeEventListener(Event.COMPLETE, onViewWork);
	
	// activate back btn
	isBackActive = true;
	// remove loading indicator 
	loadingOff();
	// get view
	var view:Group = e.target as Group;
	// set new current view
	currentView = view.id;
	
	// position window outside
	//view.percentWidth = view.percentHeight = 95;
	view.width = this.stage.stageWidth - 100;
	view.height = this.stage.stageHeight - 100;
	view.horizontalCenter = this.stage.stageWidth; 
	view.verticalCenter = 0;
	view.visible = true;
	
	// animate move-in
	TweenLite.to(view, 0.5, {horizontalCenter:0, onComplete:function():void{
		TweenLite.to(view, 0.3, {width:stage.stageWidth, height:stage.stageHeight, onComplete:function():void{
			view.x = view.y = 0;
			view.percentHeight = view.percentWidth = 100;
		}});
	}});
}

/******************************************************/
/**					LOADING INDICATION				 **/
/******************************************************/
public function loadingOn():void{
	loadingIndicator.visible = loadingIndicator.isLoading = true;
}

public function loadingOff():void{
	loadingIndicator.visible = loadingIndicator.isLoading = false;
}