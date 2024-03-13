import 'package:appcues_flutter/appcues_flutter.dart';
import 'package:flutter/material.dart';

class EmbedsScreen extends StatelessWidget {
  final String title = 'Embed Container';

  const EmbedsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          children: const [
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: AppcuesFrameView("frame1")),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text(
                  "Embedded Experiences, or Embeds for short, are experiences that are injected inline with the customer application views, rather than overlaid on top. Embeds can contain a variety of content. Any type of experience content you could show in a modal step could also be embedded into a non-modal view in the application. This pattern is commonly used for less obtrusive promotions or supplemental content, inline banners or help tips."),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: AppcuesFrameView("frame2")),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                    "Embeds are a low-code pattern, requiring customer application development work to be done to create and expose injectable view where Appcues content can reside. This involves creating and registering a special AppcuesFrame view types with the iOS and including those views in the customer app layouts. This concept of view embedding is analogous to products like the Google Ads SDKs for mobile display ads. The details of how the embed registered with the native SDKs are outside of the scope of this document, which focuses on the data model updates. SDK documentation will cover those other integration topics.")),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: AppcuesFrameView("frame3")),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                    "Before mobile embeds were supported, the Appcues mobile SDKs could render a single mobile flow at a time, modally as an overlay. These experiences could have had modal or tooltip steps, but the response from the server qualification would return a prioritized list of mobile flows and the SDK would render the highest priority item possible.\n\nWith embeds, this paradigm changes, and a qualification response may contain zero or more mobile embeds that can be rendered simultaneously, as well as zero or more mobile flows, which are handled just like before, rendering a single highest priority item. Mobile embeds and mobile flow pattern types are entirely mutually exclusive, meaning you cannot have tooltip mobile flow steps within an embed experience, for example. However, you can launch a mobile flow from a mobile embed with a button action."))
          ],
        ),
      );
}
