
import com.codezen.mse.models.Artist;
import com.codezen.mse.models.Song;
import com.facebook.graph.Facebook;
import com.facebook.graph.FacebookDesktop;

import mx.controls.Alert;
import mx.utils.ObjectUtil;

private var fbAppID:String = "255624951156266";
private var fbPermission:Array = ["offline_access", "publish_actions"];
private var fbLoggedIn:Boolean = false;
private var fbUser:Object;

// init facebook api
private function initFacebook():void{
	FacebookDesktop.init(fbAppID, onFbInit);
}

private function onFbInit(session:Object, failure:Object):void{
	if( session != null ){ // logged in
		trace('fb init ok. session exists');
		fbLoggedIn = true;
	}else if( failure != null ){
		trace("Initialized with error. Need login.");
		trace(ObjectUtil.toString(failure));
		fbLoggedIn = false;
	}
}

// attach to facebook
public function connectFacebook():void{
	FacebookDesktop.login(onFbLogin, fbPermission);
}

private function onFbLogin(session:Object, failure:Object):void{
	if( session != null ){ // logged in
		fbUser = {
			'id':session.uid,
				'token':session.accessToken,
				'fname':session.user.first_name,
				'gender':session.user.gender,
				'lname':session.user.last_name,
				'location':session.user.location.name
		};
		
		fbLoggedIn = true;
	}else if( failure != null ){
		trace(ObjectUtil.toString(failure));
		fbLoggedIn = false;
		Alert.show(failure.error.message, "Error logging into Facebook!");
	}
}

// post song to facebook
public function postFbSong(artist:String, song:String):void{
	if(!fbLoggedIn) return;
	
	var url:String = "http://mielophone.codezen.ru/get/"+encodeURIComponent(artist)+"/"+encodeURIComponent(song);
	
	trace('posting to facebook, song url: '+url);
	
	FacebookDesktop.api("/me/mielophone:listen", onFbPostMessage, {song:url}, "POST");
}

private function onFbPostMessage(result:Object, fail:Object):void{
	if( result != null ){
		trace('fb post ok');
	}else if( fail != null ){
		trace( "Alert.show('fb message post fail')" );
		trace( ObjectUtil.toString(fail) );
	}
}




