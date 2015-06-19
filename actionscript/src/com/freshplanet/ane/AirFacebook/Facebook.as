﻿package com.freshplanet.ane.AirFacebook {
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.InvokeEvent;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.system.Capabilities;

public class Facebook extends EventDispatcher {
    private var _initialized:Boolean;

    // --------------------------------------------------------------------------------------//
    //																						 //
    // 									   PUBLIC API										 //
    // 																						 //
    // --------------------------------------------------------------------------------------//

    /** Facebook is supported on iOS and Android devices. */
    public static function get isSupported():Boolean
    {
        return isIOS() || isAndroid();
    }

    private static function isIOS():Boolean
    {
        return Capabilities.version.indexOf("IOS") != -1;
    }

    private static function isAndroid():Boolean
    {
        return Capabilities.version.indexOf("AND") != -1;
    }

    public function Facebook()
    {
        if (!_instance) {
            _context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
            if (!_context) {
                log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
                return;
            }
            _context.addEventListener(StatusEvent.STATUS, onStatus);

            NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
            NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
            NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);

            _instance = this;
        }
        else {
            throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
        }
    }

    private function onActivate(event:Event):void
    {
        if (isSupported && _context != null) {

            _context.call("activateApp");
        }
    }

    private function onDeactivate(event:Event):void
    {
        if (isSupported && _context != null && isAndroid()) {

            _context.call("deactivateApp");
        }
    }

    public static function getInstance():Facebook
    {
        return _instance ? _instance : new Facebook();
    }

    /**
     * Initialize the Facebook extension.
     *
     * @param appID             A Facebook application ID (must be set for Android if there is missing FacebookId in application descriptor).
     *
     * <code>
     *     <meta-data android:name="com.facebook.sdk.ApplicationId" android:value="$FB_APP_ID"/>
     * </code>
     */
    public function init(appID:String = null):void
    {
        if (isSupported && _context != null) {

            _context.call('setNativeLogEnabled', Facebook.nativeLogEnabled);
            _context.call('initFacebook', appID);
            _initialized = true;
        } else {

            log("Can't initialize extension! Unsupported platform or context couldn't be created!")
        }
    }

    public function setDefaultShareDialogMode(shareDialogModeIOS:FBShareDialogModeIOS,
                                              shareDialogModeAndroid:FBShareDialogModeAndroid):void
    {
        if (_initialized) {

            if (isIOS()) {

                _context.call("setDefaultShareDialogMode", shareDialogModeIOS.value);
            } else if (isAndroid()) {

                _context.call("setDefaultShareDialogMode", shareDialogModeAndroid.value);
            }
        } else {

            log("You must call init() before any other method!");
        }
    }

    public function setLoginBehavior(loginBehaviorIOS:FBLoginBehaviorIOS,
                                     loginBehaviorAndroid:FBLoginBehaviorAndroid):void
    {
        if (_initialized) {

            if (isIOS()) {

                _context.call("setLoginBehavior", loginBehaviorIOS.value);
            } else if (isAndroid()) {

                _context.call("setLoginBehavior", loginBehaviorAndroid.value);
            }
        } else {

            log("You must call init() before any other method!");
        }
    }

    public function setDefaultAudience(defaultAudience:FBDefaultAudience):void
    {
        if (_initialized) {

            _context.call("setDefaultAudience", defaultAudience.value);
        } else {

            log("You must call init() before any other method!");
        }
    }

    /**
     * Fetches any deferred applink data and attempts to open the returned url
     */
//		public function openDeferredAppLink() : void
//		{
//			if (!isSupported) return;
//
//			_context.call('openDeferredAppLink');
//		}

    /** The current Facebook access token, or null if no session is open. */
    public function get accessToken():FBAccessToken
    {
        if (_initialized) {

            var accessToken:FBAccessToken = _context.call('getAccessToken') as FBAccessToken;
            log(accessToken ? accessToken.toString() : "No access token!");
            return accessToken;
        } else {

            log("You must call init() before any other method!");
            return null;
        }
    }

    public function get profile():FBProfile
    {
        if (_initialized) {

            var profile:FBProfile = _context.call('getProfile') as FBProfile;
            log(profile ? profile.toString() : "No profile!");
            return profile;
        } else {

            log("You must call init() before any other method!");
            return null;
        }
    }

    /**
     * Open a new session with a given set of read permissions.<br><br>
     *
     * @param permissions An array of requested <strong>read</strong> permissions.
     * @param callback (Optional) A callback function of the following form:
     * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
     *
     * @see #logInWithPublishPermissions()
     */
    public function logInWithReadPermissions(permissions:Array, callback:Function = null):void
    {
        if (_initialized) {

            logIn(permissions, "read", callback);
        } else {

            log("You must call init() before any other method!");
        }
    }

    /**
     * Open a new session with a given set of publish permissions.<br><br>
     *
     * @param permissions An array of requested <strong>publish</strong> permissions.
     * @param callback (Optional) A callback function of the following form:
     * <code>function myCallback(success:Boolean, userCancelled:Boolean, error:String = null)</code>
     *
     * @see #logInWithReadPermissions()
     */
    public function logInWithPublishPermissions(permissions:Array, callback:Function = null):void
    {
        if (_initialized) {

            logIn(permissions, "publish", callback);
        } else {

            log("You must call init() before any other method!");
        }
    }

    /** Close the current Facebook session and delete the token from the cache. */
    public function logOut():void
    {
        if (_initialized) {

            _context.call('logOut');
        } else {

            log("You must call init() before any other method!");
        }
    }

    /**
     * Run a Facebook request with a Graph API path.
     *
     * @param graphPath A Graph API path.
     * @param parameters (Optional) An object (key-value pairs) containing the request parameters.
     * @param httpMethod (Optional) The HTTP method to use (GET, POST or DELETE). Default is GET.
     * @param callback (Optional) A callback function of the following form:
     * <code>function myCallback(data:Object)</code>, where <code>data</code> is the parsed JSON
     * object returned by Facebook.
     */
    public function requestWithGraphPath(graphPath:String, parameters:Object = null, httpMethod:String = "GET", callback:Function = null):void
    {
        if (_initialized) {

            // Verify the HTTP method
            if (httpMethod != "GET" && httpMethod != "POST" && httpMethod != "DELETE") {
                log("ERROR - Invalid HTTP method: " + httpMethod + " (must be GET, POST or DELETE)");
                return;
            }

            // Separate parameters keys and values
            var keys:Array = [];
            var values:Array = [];
            for (var key:String in parameters) {
                var value:String = parameters[key] as String;
                if (value) {
                    keys.push(key);
                    values.push(value);
                }
            }

            // Register the callback
            var callbackName:String = getNewCallbackName(callback);

            // Execute the request
            _context.call('requestWithGraphPath', graphPath, keys, values, httpMethod, callbackName);
        } else {

            log("You must call init() before any other method!");
        }
    }

    /**
     * Determine if we can open a native share dialog with the given parameters.
     * Call this method to decide whether you should use <code>shareStatusDialog</code> or <code>webDialog</code>
     *
     * @see #setDefaultShareDialogMode
     */
    public function canPresentShareDialog():Boolean
    {
        if (_initialized) {

            return _context.call('canPresentShareDialog');
        } else {

            log("You must call init() before any other method!");
            return false;
        }
    }

    /**
     * Open a native Facebook dialog for sharing a link
     * This requires that the Facebook app is installed on the device,
     * To make sure this succeeds, call canPresentShareDialog, otherwise
     * you can fall back to a web view with the <code>webDialog</code> method
     *
     * @param link (Optional) Link to share.
     * @param name (Optional) Title of the publication.
     * @param caption (Optional) Short summary of the link content.
     * @param description (Optional) Description of the link content.
     * @param pictureUrl (Optional) Url of the attached picture.
     * @param callback (Optional) A callback function of the following form:
     * <code>function myCallback(data:Object)</code>, where <code>data</code> is the parsed JSON
     * object returned by Facebook.
     */
    public function shareLinkDialog(contentUrl:String = null,
                                    contentTitle:String = null,
                                    contentDescription:String = null,
                                    imageUrl:String = null,
                                    useShareApi:Boolean = false,
                                    callback:Function = null):void
    {
        if (_initialized) {

            _context.call('shareLinkDialog', contentUrl, contentTitle, contentDescription, imageUrl, useShareApi, getNewCallbackName(callback));
        } else {

            log("You must call init() before any other method!");
        }
    }

    // --------------------------------------------------------------------------------------//
    //																						 //
    // 									 	PRIVATE API										 //
    // 																						 //
    // --------------------------------------------------------------------------------------//

    private static const EXTENSION_ID:String = "com.freshplanet.AirFacebook";

    private static var _instance:Facebook;
    /**
     * If <code>true</code>, logs will be displayed at the ActionScript level.
     */
    public static var logEnabled:Boolean = false;
    /**
     * If <code>true</code>, logs will be displayed at the native level.
     * You must change this before first call of getInstance() to actually see logs in native.
     */
    public static var nativeLogEnabled:Boolean = false;

    private var _context:ExtensionContext;
    private var _openSessionCallback:Function;
    private var _requestCallbacks:Object = {};

    private function logIn(permissions:Array, type:String, callback:Function = null):void
    {
        if (!isSupported) return;

        _openSessionCallback = callback;
        _context.call('logInWithPermissions', permissions, type);
    }

    private function getNewCallbackName(callback:Function):String
    {
        // Generate callback name based on current time
        var date:Date = new Date();
        var callbackName:String = date.time.toString();

        // Clean up old callback if the name already exists
        if (_requestCallbacks.hasOwnProperty(callbackName)) {
            delete _requestCallbacks[callbackName]
        }

        // Save new callback under this name
        _requestCallbacks[callbackName] = callback;

        return callbackName;
    }

    private function onInvoke(event:InvokeEvent):void
    {
        log("FACEBOOK about to call handleOpenURL on args: [" + event.arguments.join(",") + "] with reason: " + event.reason);

        if (Capabilities.manufacturer.indexOf("iOS") != -1) {
            if (event.arguments != null && event.arguments.length > 0) {
                var url:String = event.arguments[0] as String;
                var sourceApplication:String = event.arguments[1] as String;
                var annotation:String = event.arguments[2] as String;

                _context.call("handleOpenURL", url, sourceApplication, annotation);
            }
        }
    }

    private function onStatus(event:StatusEvent):void
    {
        var callback:Function;

        if (event.code.indexOf("SESSION") != -1) // If the event code contains SESSION, it's an open/reauthorize session result
        {
            var success:Boolean = (event.code.indexOf("SUCCESS") != -1);
            var userCancelled:Boolean = (event.code.indexOf("CANCEL") != -1);
            var error:String = (event.code.indexOf("ERROR") != -1) ? event.level : null;

            callback = _openSessionCallback;

            _openSessionCallback = null;

            if (callback != null) callback(success, userCancelled, error);
        }
        else if (event.code == "LOGGING") // Simple log message
        {
            // NOTE: logs from native should go only to as3 log
            as3Log(event.level, "NATIVE");
        }
        else if (event.code.indexOf("SHARE") != -1) {
            var dataArr:Array = event.code.split("_");
            if (dataArr.length == 3) {
                var status:String = dataArr[1];
                var callbackName:String = dataArr[2];

                callback = _requestCallbacks[callbackName];

                if (callback != null) {

                    callback(status == "SUCCESS", status == "CANCELLED", status == "ERROR" ? event.level : null);

                    delete _requestCallbacks[event.code];
                }
            }
        }
        else // Default case: we check for a registered callback associated with the event code
        {
            if (_requestCallbacks.hasOwnProperty(event.code)) {
                callback = _requestCallbacks[event.code];
                var data:Object;

                if (callback != null) {
                    try {
                        data = JSON.parse(event.level);
                    }
                    catch (e:Error) {
                        log("ERROR - " + e);
                    }

                    callback(data);

                    delete _requestCallbacks[event.code];
                }
            }
        }
    }

    private function log(message:String):void
    {
        if (Facebook.logEnabled) {
            as3Log(message, "AS3");
        }
        if (Facebook.nativeLogEnabled) {
            nativeLog(message);
        }
    }

    private function as3Log(message:String, prefix:String):void
    {
        trace("[AirFacebook][" + prefix + "] " + message);
    }

    private function nativeLog(message:String):void
    {
        if (_context != null) {

            _context.call('nativeLog', message);
        }
    }
}
}
