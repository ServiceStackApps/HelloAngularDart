// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:servicestack/client.dart';
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
}
