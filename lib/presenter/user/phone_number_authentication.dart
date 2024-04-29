import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../services/network/websocket_services.dart';

class AuthenticationState {
  final bool isAutheticated;

  AuthenticationState({this.isAutheticated = false});
}

class PhoneNumberAuthenticationInfo {
  final String phoneNumber;
  final String verificationCode;

  PhoneNumberAuthenticationInfo(
      {required this.phoneNumber, required this.verificationCode});
}

class PhoneNumberAuthenticationPresenter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authenticationProvider);
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.phone),
            SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                  context, '전화번호를 입력해주세요.', false, TextInputType.phone, ref),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                stompClientForAuthentication.activate();
                // Add phone number authentication logic here.
                sendPhoneNumber('01092566504');
              },
              child: Text("인증 번호 받기"),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  context, '인증번호를 입력해주세요.', false, TextInputType.number, ref),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, String hintText, bool isPassword,
      TextInputType type, WidgetRef ref) {
    return TextField(
      autofillHints: type == TextInputType.phone
          ? [AutofillHints.telephoneNumber]
          : (type == TextInputType.number ? [AutofillHints.oneTimeCode] : null),
      keyboardType: type,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

final authenticationProvider =
    StateNotifierProvider<AuthenticationNotifier, AuthenticationState>((ref) {
  return AuthenticationNotifier();
});

class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  AuthenticationNotifier() : super(AuthenticationState());

  void authenticate(String phoneNumber, String verificationCode) {
    // Add authentication logic here.
  }
}

final stompClientForAuthentication = StompClient(
  config: StompConfig(
    url: WebSocketService.url,
    onConnect: onConnect,
  ),
);

void onConnect(StompFrame frame) {
  print('Connected to the server');
  stompClientForAuthentication.activate();
}

void sendPhoneNumber(String phoneNumber) {
  stompClientForAuthentication.subscribe(
      destination: "/user/signup/generate-verification-code/${phoneNumber}",
      callback: (frame) {});
  stompClientForAuthentication.send(
      destination: "/user/signup/generate-verification-code/${phoneNumber}",
      body: phoneNumber,
      headers: {'content-type': 'application/json'});
}
