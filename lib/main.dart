
// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'main_app.dart';

void main() {
  runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
          body: MainApp()),
    theme: ThemeData(fontFamily: 'Schyler'),

  ));
}


