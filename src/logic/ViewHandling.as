import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import spark.components.Group;

/******************************************************/
/**						VARS						 **/
/******************************************************/
// back button activator
private var isBackActive:Boolean = false;
// back button display timer
private var backTimer:Timer;
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
}

/******************************************************/
/**				BACK BUTTON HANDLING			 	 **/
/******************************************************/
private function onAppMouseMove(e:MouseEvent):void{
	if( !isBackActive ) return;
	
	if( e.stageX < 20 ){	
		backTimer.start();
	}else{
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
	// get new view string
	var newView:String = viewHistory.pop();
	// if new is home 
	if( newView == "homeView" ){
		isBackActive = false;
	}
	
	// hide button
	TweenLite.to(backButton, 0.3, {left:-36});
	
	// get current view
	var view:Group = this[currentView];
	// reset size and position to absolute 
	view.horizontalCenter = view.verticalCenter = 0;
	view.height = stage.height; 
	view.width = nativeWindow.width;
	
	// animate move-out
	TweenLite.to(view, 0.3, {width:nativeWindow.width-100, height:stage.height-100, onComplete:function():void{
		TweenLite.to(view, 0.5, {horizontalCenter:nativeWindow.width, onComplete:function():void{
			view.visible = false;
		}});
	}});
}

/******************************************************/
/**					VIEW CHANGING					 **/
/******************************************************/

public function changeView(view:*):void{
	// save last view
	viewHistory.push(currentView);
	
	// show loader
	loadingIndicator.visible = loadingIndicator.isLoading = true;
	
	// do view work
	view.addEventListener(Event.COMPLETE, onViewWork);
	view.doWork();
}

private function onViewWork(e:Event):void{
	e.target.removeEventListener(Event.COMPLETE, onViewWork);
	
	// activate back btn
	isBackActive = true;
	// remove loading indicator 
	loadingIndicator.visible = loadingIndicator.isLoading = false;
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
		TweenLite.to(view, 0.3, {width:nativeWindow.width, height:stage.stageHeight, onComplete:function():void{
			view.x = view.y = 0;
			view.percentHeight = view.percentWidth = 100;
		}});
	}});
}