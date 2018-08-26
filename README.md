# Hello AngularDart

[AngularDart](https://webdev.dartlang.org/angular) App utilizing [ServiceStack's native support for Dart](http://docs.servicestack.net/dart-add-servicestack-reference) and [AngularDart Components](https://webdev.dartlang.org/components).

The [HelloAngularDart](https://github.com/ServiceStackApps/HelloAngularDart) project demonstrates the same functionality [as Hello Flutter](https://github.com/ServiceStackApps/HelloFlutter) in an AngularDart Web App running inside a Web Browser.


To get started add the `servicestack` dependency to your apps [pubspec.yaml](https://github.com/ServiceStackApps/HelloAngularDart/blob/master/pubspec.yaml):

```yaml
dependencies:
  servicestack: ^1.0.5
```

Saving `pubspec.yaml` automatically runs [pub get](https://www.dartlang.org/tools/pub/cmd/pub-get) to install any new dependencies in your App. 


The only difference [with Hello Flutter](https://github.com/ServiceStackApps/HelloFlutter) is importing `servicestack/web_client.dart` containing the `JsonWebClient`:

```dart
import 'package:servicestack/web_client.dart';
```

and changing the clients to use the `JsonWebClient` instead, e.g:

```dart
var testClient = new JsonWebClient(TestBaseUrl);
var techstacksClient = new JsonWebClient(TechStacksBaseUrl);
```

But otherwise the actual client source code for all of the Typed API requests remains exactly the same. 

## Run

Follow the [AngularDart guide](https://webdev.dartlang.org/angular/guide/setup#run-the-app) to learn about developing AngularDart Web Apps.

After cloning this project run `pub get` to install all the App's dependencies:

    $ pub get

Then run `webdev serve` to start a watched live reload of the App which you can customize and see changes in real-time:

    $ webdev serve

### Description

The `HelloAngularDart` App is contained within the [hello_world](https://github.com/ServiceStackApps/HelloAngularDart/tree/master/lib/src/hello_world) component with all Dart logic in:

#### [hello_world.dart](https://github.com/ServiceStackApps/HelloAngularDart/blob/master/lib/src/hello_world/hello_world.dart)

```dart
import 'dart:typed_data';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:servicestack/web_client.dart';

import '../dtos/test.dtos.dart';
import '../dtos/techstacks.dtos.dart';

@Component(
  selector: 'hello-world',
  styleUrls: const ['hello_world.css'],
  templateUrl: 'hello_world.html',
)
class HelloWorldComponent {
  var result = "";
  var imageSrc = "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="; // 1x1 pixel
  static const TestBaseUrl = "http://test.servicestack.net";
  static const TechStacksBaseUrl = "https://www.techstacks.io";
  var testClient = new JsonWebClient(TestBaseUrl);
  var techstacksClient = new JsonWebClient(TechStacksBaseUrl);

  doAsync() async {
    var r = await testClient.get(new Hello(name: "Async"));
    result = r.result;
  }

  doAuth() async {
    var auth = await testClient.post(new Authenticate(
        provider: "credentials", userName: "test", password: "test"));
    var r = await testClient.get(new HelloAuth(name: "Auth"));
    result = "${r.result} your JWT is: ${auth.bearerToken}";
  }

  doJWT() async {
    var auth = await testClient.post(new Authenticate(
        provider: "credentials", userName: "test", password: "test"));

    var newClient = new JsonWebClient(TestBaseUrl)
      ..refreshToken = auth.refreshToken;
    var r = await newClient.get(new HelloAuth(name: "JWT"));
    result = "${r.result} your RefreshToken is: ${auth.refreshToken}";
  }

  doQuery() async {
    var techs = await techstacksClient
        .get(new FindTechnologies(), args: {"slug": "flutter"});
    var posts = await techstacksClient.get(new QueryPosts(
        anyTechnologyIds: [techs.results[0].id],
        types: ['Announcement', 'Showcase'])
      ..take = 1);
    result = "Latest Flutter Announcement:\n“${posts.results[0].title}”";
  }

  doBatch() async {
    var requests = ['foo', 'bar', 'qux'].map((name) => new Hello(name: name));
    var responses = await testClient.sendAll(requests);
    result = "Batch Responses:\n${responses.map((r) => r.result).join('\n')}";
  }

  doImage() async {
    Uint8List bytes = await testClient.get(new HelloImage(
        name: "Flutter",
        fontFamily: "Roboto",
        background: "#0091EA",
        width: 500,
        height: 170));

    result = "";
    imageSrc = "data:image/png;base64," + base64.encode(bytes);
  }
}
```

#### [hello_world.html](https://github.com/ServiceStackApps/HelloAngularDart/blob/master/lib/src/hello_world/hello_world.html)

Which uses this template markup to render its UI:

```html
<div>
    <button (click)="doAsync()">Async</button>
    <button (click)="doAuth()">Auth</button>
    <button (click)="doJWT()">JWT</button>
    <button (click)="doQuery()">Query</button>
    <button (click)="doBatch()">Batch</button>
    <button (click)="doImage()">Image</button>
</div>

<div id="result">{{result}}</div>

<img src="{{imageSrc}}">
```

Where it runs a functionally equivalent App in a browser:

![](https://raw.githubusercontent.com/ServiceStack/docs/master/docs/images/dart/angulardart/helloangulardart-01.png)