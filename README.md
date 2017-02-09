CircleOfFifths
===

Fully customisable IBDesignable circle of fifths implementation.

![alt tag](https://github.com/cemolcay/CircleOfFifths/blob/master/demo.png?raw=true)

Requirements
----

* Swift 3+
* iOS 8.0+
* tvOS 9.0+
* macOS 10.9+

Install
----

```
pod 'CircleOfFifths'
```

You need to add this post installer script to your podfile in order to use @IBDesignable libraries with pods.     
More information on this [cocoapods issue](https://github.com/CocoaPods/CocoaPods/issues/5334)

```
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']
  end
end
```

Usage
----

* CircleOfFifths just a regular `UIView` subclass with custom `CALayer` drawing with customisable `@IBInspectable` properties.  
* It can render any `Scale` type in any key of this [music theory library](https://github.com/cemolcay/MusicTheory).  
* Just set the `scale` parameter in order to change scale and/or key of circle.  
* Also draws another customisable circle below to show related major, minor and diminished chords of the scale in circle.  

Credits
----

* Thanks to http://randscullard.com/CircleOfFifths/
