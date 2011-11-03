import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.playr.Playr;
import com.codezen.mse.services.LastfmScrobbler;

import flash.net.SharedObject;

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
private var nextRandomPos:int;
public var playPos:int;

// tweaks
private var lastPositionMilliseconds:Number;

// Scrobbler 
private var scrobbler:LastfmScrobbler;
private var scrobblerSettings:SharedObject;
private var scrobbleName:String;
private var scrobblePass:String;
private var trackScrobbled:Boolean;

// facebook stuff
private var fbSongPosted:Boolean;