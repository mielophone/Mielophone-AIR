import flash.events.Event;
import flash.filesystem.File;

import mielophone.extensions.ExtensionsManager;

import mx.core.FlexGlobals;

private var pluginManager:ExtensionsManager;

private function initUIExtensions():void{
	pluginManager = new ExtensionsManager( [File.applicationDirectory.resolvePath("extensions/").nativePath, File.applicationStorageDirectory.resolvePath("extensions/").nativePath] );
}