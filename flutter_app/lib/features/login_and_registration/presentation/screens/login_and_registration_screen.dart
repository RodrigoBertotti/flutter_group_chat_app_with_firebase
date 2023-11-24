import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/center_content_widget.dart';
import '../../../../core/presentation/widgets/my_appbar_widget.dart';
import '../../../../core/presentation/widgets/my_scaffold.dart';
import '../../../../core/presentation/widgets/waves_background/waves_background.dart';
import '../widgets/separator.dart';
import 'content/login_content.dart';
import 'content/register_content.dart';


class LoginAndRegistrationScreen extends StatefulWidget {
  static const String route = '/login';

  const LoginAndRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<LoginAndRegistrationScreen> createState() => _LoginAndRegistrationScreenState();
}

class _LoginAndRegistrationScreenState extends State<LoginAndRegistrationScreen> {
  final ValueNotifier<String?> notifyError = ValueNotifier<String?>(null);
  late LoginAndRegistrationContent content;
  String? successMessage;

  @override
  void initState() {
    super.initState();
    final List<dynamic> goToLoginHelper = [];
    loginContent({String? email}) => LoginContent(email: email, notifyError: notifyError, goToLogin: (message, email) => (goToLoginHelper[0] as GoToLoginCallback)(message, email));
    goToLoginHelper.add(
        (message, email) => setState(() {
          content = loginContent(email: email,);
          successMessage = message;
        })
    );
    content = loginContent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        appBar: MyAppBarWidget(
          context: context,
          withBackground: true,
          child: Text(content.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        ),
        background: const WavesBackground(),
        body: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * .1,),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white.withOpacity(.95)
                  ),
                  padding: const EdgeInsets.all(30),
                  child: const Icon(Icons.person, size: 80, color: Colors.blue),
                ),
                const SizedBox(height: 45,),

                content,

                // error message
                ValueListenableBuilder(
                    valueListenable: notifyError,
                    builder: (context, error, widget) => error == null || error.isEmpty
                        ? Container()
                        : Column(
                      children: [
                        separator,
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              child: Text(error, style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: .8, fontWeight: FontWeight.w600)),
                            )
                        )
                      ],
                    )
                ),

                const SizedBox(height: 15,),
                Align(
                  alignment: const Alignment(.93,0),
                  child: InkWell(
                    child: Ink(
                      child: Text(content.nextContent.title, style: const TextStyle(color: Colors.white, letterSpacing: 1, fontWeight: FontWeight.w800)),
                    ),
                    onTap: () {
                      setState(() {
                        notifyError.value = null;
                        content = content.nextContent;
                      });
                    },
                  ),
                ),

                if(successMessage?.isNotEmpty == true)
                  ...[
                    const SizedBox(height: 20,),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: Text(successMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.green[900], fontSize: 15, letterSpacing: .8, fontWeight: FontWeight.w600)),
                        )
                    )
                  ],

                const SizedBox(height: 50,)
              ],
            ),
          ),
        )
    );
  }
}

abstract class LoginAndRegistrationContent extends Widget {
  const LoginAndRegistrationContent({super.key});

  String get title;
  LoginAndRegistrationContent get nextContent;
}

