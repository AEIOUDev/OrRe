import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:orre/widget/appbar/static_app_bar_widget.dart';
import 'package:orre/widget/background/waveform_background_widget.dart';
import 'package:orre/widget/button/big_button_widget.dart';
import 'package:orre/widget/text/text_widget.dart';

import '../../services/debug.services.dart';

class AgreementScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printd("\n\n AgreementScreen 진입");
    var agreement = '''단모음데브 개인정보 처리방침

제1조 (목적)
본 약관은 단모음데브(이하 "회사")가 제공하는 오리 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (수집하는 개인정보 항목)
회사는 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다.
1. 전화번호
2. GPS 기반 위치 정보

제3조 (개인정보 수집 및 이용 목적)
회사는 수집한 개인정보를 다음의 목적을 위해 이용합니다.
1. 서비스 제공 및 운영: 원격 웨이팅, 원격 테이블 주문 서비스 제공
2. 이용자 식별 및 인증
3. 서비스 관련 공지사항 전달 및 고객 문의 응대

제4조 (개인정보의 보유 및 이용 기간)
1. 회사는 이용자의 개인정보를 탈퇴 시까지 보유 및 이용합니다.
2. 개인정보 보유 기간이 경과하거나, 처리 목적이 달성된 경우 해당 정보를 지체 없이 파기합니다.

제5조 (개인정보의 제3자 제공)
회사는 이용자의 개인정보를 원칙적으로 외부에 제공하지 않습니다. 다만, 다음의 경우에는 예외로 합니다.
1. 이용자가 사전에 동의한 경우
2. 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우

제6조 (개인정보의 처리 위탁)
회사는 서비스 향상을 위해 이용자의 개인정보 처리를 외부에 위탁할 수 있습니다. 이 경우, 회사는 위탁받은 업체가 개인정보 보호 법령에 따라 개인정보를 안전하게 처리하도록 필요한 사항을 규정합니다.

제7조 (이용자의 권리)
이용자는 언제든지 자신의 개인정보를 조회하거나 수정할 수 있으며, 개인정보의 처리에 대한 동의 철회, 삭제를 요청할 수 있습니다.
1. 개인정보 조회, 수정: 서비스 내 설정 메뉴를 통해 가능합니다.
2. 동의 철회 및 삭제 요청: 고객센터를 통해 요청할 수 있습니다.

제8조 (개인정보의 파기절차 및 방법)
회사는 개인정보 보유 기간의 경과, 처리 목적 달성 등으로 개인정보가 불필요하게 되었을 때에는 해당 정보를 지체 없이 파기합니다.
1. 전자적 파일 형태의 정보는 복구 및 재생할 수 없는 방법을 사용하여 삭제합니다.
2. 종이에 출력된 개인정보는 분쇄기로 분쇄하거나 소각을 통하여 파기합니다.

제9조 (개인정보 보호책임자)
회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 이용자의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.

개인정보 보호책임자: 정민호
연락처: 010-9256-6504
이메일: myknow00@naver.com

제10조 (개인정보 처리방침 변경)
회사는 개인정보 처리방침을 변경하는 경우에는 변경 및 시행 시기, 변경된 내용을 지속적으로 공개합니다. 이 방침은 2024년 5월 16일부터 시행됩니다.
''';
    return WaveformBackgroundWidget(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.25.sh),
          child: StaticAppBarWidget(
              title: '오리 서비스 이용약관',
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  context.pop();
                },
              )),
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16 * 5),
                  Row(
                    children: [
                      Icon(Icons.push_pin),
                      SizedBox(width: 10),
                      TextWidget(
                        '오리 서비스 이용약관 요약',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 35),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xffDFDFDF), width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextWidget(
                                  '수집 목적',
                                  fontSize: 16,
                                  textAlign: TextAlign.start,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: TextWidget(
                                  ': 서비스 이용',
                                  fontSize: 16,
                                  textAlign: TextAlign.start,
                                  color: Color(0xFF999999),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextWidget(
                                  '수집 항목',
                                  fontSize: 16,
                                  textAlign: TextAlign.start,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: TextWidget(
                                  ': 전화번호, 위치',
                                  fontSize: 16,
                                  textAlign: TextAlign.start,
                                  color: Color(0xFF999999),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextWidget(
                                  '보유 및 이용 기간',
                                  fontSize: 16,
                                  textAlign: TextAlign.start,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: TextWidget(
                                  ': 보유 및 이용하는 기간은 탈퇴 시까지',
                                  fontSize: 16,
                                  textAlign: TextAlign.start,
                                  color: Color(0xFF999999),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.push_pin),
                      SizedBox(width: 10),
                      TextWidget(
                        '전체 이용약관 보기',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 35),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height * 0.3,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xffDFDFDF), width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          agreement,
                          style: TextStyle(
                            fontFamily: 'Dovemayo_gothic',
                            fontSize: 16,
                            color: Color(0xFF999999),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: BigButtonWidget(
                      onPressed: () {
                        print("이용약관에 동의하셨습니다.");
                        context.push('/user/signup');
                      },
                      text: '동의합니다',
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
