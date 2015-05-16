#
#  Be sure to run `pod spec lint DMAutoInvalidation.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "DMAutoInvalidation"
  s.version      = "2.0.0"
  s.summary      = "Block-based observers that automatically unregister themselves."

  s.description  = <<-DESC
                   The DMAutoInvalidation class provides behavior to attach an
                   observer object to an owning object. When the owning object
                   is *about to* deallocate, `-invalidate` is sent to the
                   observer object.

                   This library includes pre-built observers for NSNotifcation,
                   key-value observing, Core Data managed objects (observing
                   `NSManagedObjectContextObjectsDidChangeNotification` and
                   testing if an observed managed object's attributes or
                   relationships have changed), and FSEvents (on Mac desktop
                   only).

                   The purpose of this is to model observer registration as an
                   object, each with an associated block. This removes the need
                   for the owning objects to dispatch to the desired code (if
                   the observation always funnels through a single callback,
                   such as key-value observing), and removes the need to
                   manually unregister for notifications. With that, the
                   possibility of *forgetting* to unregister for a notification
                   (and the subsequent crash or bad behavior) is removed.
                   DESC

  s.homepage     = "https://github.com/jmah/DMAutoInvalidation"


  s.license      = { :type => "Apache", :file => "LICENSE.txt" }


  s.author       = { "Jonathon Mah" => "me@JonathonMah.com", "Wil Shipley" => "wjs@mac.com" }

  s.source       = { :git => "https://github.com/jmah/DMAutoInvalidation.git", :tag => s.version.to_s }

  s.source_files  = "**/*.{h,m}"
  s.exclude_files = "DMBlockUtilities/DMBlockUtilitiesTest", "DMKeyValueObserver/DMKeyValueObserverTest"

  s.requires_arc = true
end
