# Configuring Views for Anchored Tooltips

The Appcues Flutter plugin supports anchored tooltips targeting widgets in your application's layout.

Tooltips in Flutter utilize the [Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html) tree that a Flutter application creates to describe each screen's layout. Layout information is provided automatically that can be used to target many views in your application. Additionally, you can instrument your layout with Semantics widgets to provide custom tag information, and have full control over how your target elements are identified.

The Semantics information allows the Appcues Flutter plugin to create a mobile view selector for each view. This selector is used by the Appcues Mobile Builder to create and target anchored tooltips. When a user qualifies for a flow, this selector is used to render the anchored tooltip content.

## Enabling Element Targeting

Appcues anchored tooltip support in Flutter uses a listener for Semantics tree updates, using the PipelineOwner [ensureSemantics](https://api.flutter.dev/flutter/rendering/PipelineOwner/ensureSemantics.html) method. Usage of this feature is optional. To enable anchored tooltip support call:
```dart
var handle = SemanticsBinding.instance.ensureSemantics(); // only required if using Flutter 3.16+
Appcues.enableElementTargeting();
```

> [!IMPORTANT]
> If using Flutter 3.16 or above, the additional SemanticsBinding call shown above is required, due to changes in how the Flutter SDK generates the Semantics updates.

If it is necessary to disable this feature in any section of an application, call:
```dart
handle.dispose(); // if using Flutter 3.16+
Appcues.disableElementTargeting();
```

To support capturing screens for usage in the mobile builder to target anchored tooltips, the element targeting feature must be enabled.

## Instrumenting Layouts with Additional Semantics

As noted above, the default Semantics information about your application's layout will be available automatically. To have full control over how a view is identified, use the `AppcuesView` SemanticsTag, and provide a specific identifier String value.

For example, an application layout contains an ElevatedButton:
```dart
ElevatedButton(
    style: ... ,
    onPressed: () { ... },
    child: const Text('Save Profile'),
)
```

Wrap this widget with Semantics, and provide a `tagForChildren` value that contains an instance of an `AppcuesView` tag, with the specific identifier for targeting.
```dart
Semantics(
    tagForChildren: const AppcuesView("btnSaveProfile"),
    child: ElevatedButton(
        style: ... ,
        onPressed: () { ... },
        child: const Text('Save Profile'),
    )
)     
```

The identifier `btnSaveProfile` will now be available to target anchored tooltips in the mobile builder. The value is also used to locate the view to anchor the tooltip at runtime in your Flutter application. 

The best way to ensure great performance of Flutter anchored tooltips in Appcues is to set a unique `AppcuesView` tag in Semantics, on each element that may be targeted. The `AppcuesView` identifier value must be unique on the screen where an anchored tooltip may be targeted.

## Other Considerations

### Selector Uniqueness
Ensure that view identifiers used for selectors are unique within the visible views on the screen at the time an anchored tooltip is attempting to render. If no unique match is found, the Appcues flow will terminate with an error. It is not required that selectors are globally unique across the application, but they must be on any given screen layout.

### Consistent View Identifiers
Maintain consistency with view identifiers as new versions of the app are released. For example, if a key navigation tab was using an identifier like "Home Tab" in several versions of the application, then changed to "Home" - this would break the ability for selectors using "Home Tab" to be able to find that view and target a tooltip in the newer versions of the app. You could build multiple flows targeting different versions of the application, but it helps keep things simplest if consistent view identifiers can be maintained over time.
