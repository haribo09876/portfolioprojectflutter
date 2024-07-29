import 'dart:async';
import 'package:flutter/material.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

class VPNService {
  late OpenVPN engine;
  VpnStatus? status;
  String? stage;

  VPNService() {
    engine = OpenVPN(
      onVpnStatusChanged: (data) {
        status = data;
        print("VPN Status: $data");
      },
      onVpnStageChanged: (data, raw) {
        stage = raw;
        print("VPN Stage: $raw");
      },
    );

    engine.initialize(
      groupIdentifier: "group.com.laskarmedia.vpn",
      providerBundleIdentifier:
          "id.laskarmedia.openvpnFlutterExample.VPNExtension",
      localizedDescription: "VPN by Nizwar",
      lastStage: (stage) {
        this.stage = stage.name;
      },
      lastStatus: (status) {
        this.status = status;
      },
    );
  }

  Future<void> connect() async {
    await engine.connect(
      _config,
      "JPN",
      username: _defaultVpnUsername,
      password: _defaultVpnPassword,
      certIsRequired: true,
    );
  }

  void disconnect() {
    engine.disconnect();
  }

  Future<void> requestPermission() async {
    await engine.requestPermissionAndroid();
  }
}

const String _defaultVpnUsername = "";
const String _defaultVpnPassword = "";
String get _config => "HERE IS YOUR OVPN SCRIPT";
