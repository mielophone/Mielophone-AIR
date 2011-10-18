package mielophone.extensions
{
	import flash.events.IEventDispatcher;

	public interface IMUIExtension
	{
		// plugin details
		function get PLUGIN_NAME():String;
		function get AUTHOR_NAME():String;
	}
}