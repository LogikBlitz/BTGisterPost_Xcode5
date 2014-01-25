## For XCode 5.\* 

## BTGisterPost for XCode 5.\*  
A small plug-in for Xcode 5.\* that allows for posting of Gist's directly from Xcode.
It is purposely meant to be very small and not to intrusive.
It is not the most pretty little thing, but it gets the job done.   
Think of it as your friendly Gist hammer:-D.  

__It has been tested in Xcode 5.0.2 on OS X 10.9\* and will NOT work in Xcode 4 and below
since Xcode 5 now uses ARC.__

## Notes

- Set `XCPluginHasUI` in `Info.plist` to `YES` to disable your plugin
- Unlike Xcode 4, Xcode 5 uses ARC.
- Add the build UUIDs for the versions of Xcode you wish to support to `DVTPlugInCompatibilityUUIDs` in `Info.plist`. This can be found by running:

  <pre>defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID</pre>
  
  Not doing this will effectually render the plugin unusable, since it will not be accessible thru Xcode.

### Getting started
If you just want to install the plug-in the best way is to use the XCode package manager [Alcatraz](http://mneorr.github.com/Alcatraz).
This plug-in is available in the package list, just look for **BTGisterPost** and check it for installation.  
You can also build the plug-in directly from the source:
* Clone this repository.
* Open the project in Xcode 5+
* Build the solution -- the plug-in will automatically be installed.
* Restart Xcode for the plug-in to be activated.

#### Features
* The plugin will create a menupoint in the `edit` menu: `Post Gist To Github`. allowing you to post your gist.
* The plugin creates the shortcut `⌥ + c` i.e. `(option + c)` for faster posting of gist's.
 
* It will use the currently selected text to create a gist. 
* It will automatically retrieve the name of the current file and use it as the default gist name 
* It uses the built in __User Notificationcenter in OS X__ to inform of the progress of the Gist post.
Clicking the notification will open the gist in a browser.

##### GitHub user credentials.
To post a gist the plug-in requires a **username*** and **password** to a valid GitHub account. Your information is not in any way used for anything else but creating Gist's. If you have any concerns feel free to check the source.

### Uninstall
To uninstall the plug-in simply delete it from the folder where it resides:
`~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/BTGisterPost.xcplugin`  
Or if using **Alzatraz** just uncheck the plug-in in the package list, and it should be removed.  
Remember to restart Xcode for the removal to take effect.

###
The project uses [Cocoa Pods](http://cocoapods.org/) so make sure you have it installed on your system and follow normal 
pod procedure.

### Contributions
If you would like to contribute to the plug-in, simply fork the project and submit a pull request. See [GitHub help](https://help.github.com/articles/fork-a-repo)

### License
The MIT License (MIT)

Copyright (c) 2013 Thomas Blitz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


