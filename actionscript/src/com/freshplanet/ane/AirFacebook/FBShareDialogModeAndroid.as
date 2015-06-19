/**
 * Created by nodrock on 17/06/15.
 */
package com.freshplanet.ane.AirFacebook {
public class FBShareDialogModeAndroid {

    public static const AUTOMATIC:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 0);
    public static const NATIVE:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 1);
    public static const WEB:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 2);
    public static const FEED:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 3);

    private var _value:int;

    public function FBShareDialogModeAndroid(access:Class, value:int)
    {
        if(access != Private){
            throw new Error("Private constructor call!");
        }

        _value = value;
    }

    public function get value():int
    {
        return _value;
    }
}
}

final class Private{}
