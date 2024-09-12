import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../utils/Extensions/context_extension.dart';
import '../utils/Extensions/StringExtensions.dart';

import '../../main.dart';
import '../../service/AuthService1.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';
import '../utils/images.dart';
import 'TermsConditionScreen.dart';

class SignUpScreen extends StatefulWidget {
  final bool socialLogin;
  final String? userName;
  final bool isOtp;
  final String? countryCode;
  final String? privacyPolicyUrl;
  final String? termsConditionUrl;

  SignUpScreen(
      {this.socialLogin = false,
      this.userName,
      this.isOtp = false,
      this.countryCode,
      this.privacyPolicyUrl,
      this.termsConditionUrl});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthServices authService = AuthServices();

  TextEditingController firstController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode confirmPass = FocusNode();

  bool mIsCheck = false;
  bool isAcceptedTc = false;

  String countryCode = defaultCountryCode;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await saveOneSignalPlayerId().then((value) {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      if (isAcceptedTc) {
        appStore.setLoading(true);
        Map req = {
          'first_name': firstController.text.trim(),
          'last_name': lastNameController.text.trim(),
          'username': widget.socialLogin
              ? widget.userName
              : userNameController.text.trim(),
          'email': emailController.text.trim(),
          "user_type": "rider",
          "contact_number": widget.socialLogin
              ? '${widget.countryCode}${widget.userName}'
              : '$countryCode${phoneController.text.trim()}',
          'password':
              widget.socialLogin ? widget.userName : passController.text.trim(),
          "player_id": sharedPref.getString(PLAYER_ID).validate(),
          if (widget.socialLogin) 'login_type': 'mobile',
        };

        await signUpApi(req).then((value) {
          authService
              .signUpWithEmailPassword(getContext,
                  mobileNumber: widget.socialLogin
                      ? '${widget.countryCode}${widget.userName}'
                      : '$countryCode${phoneController.text.trim()}',
                  email: emailController.text.trim(),
                  fName: firstController.text.trim(),
                  lName: lastNameController.text.trim(),
                  userName: widget.socialLogin
                      ? widget.userName
                      : userNameController.text.trim(),
                  password: widget.socialLogin
                      ? widget.userName
                      : passController.text.trim(),
                  userType: RIDER,
                  isOtpLogin: widget.socialLogin)
              .then((res) async {
            //
          }).catchError((e) {
            appStore.setLoading(false);
            toast('$e');
          });
        }).catchError((error) {
          appStore.setLoading(false);
        });
      } else {
        toast(language.pleaseAcceptTermsOfServicePrivacyPolicy);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: context.statusBarHeight + 16),
                  ClipRRect(
                      borderRadius: radius(10),
                      child: Image.asset(ic_app_logo, width: 100, height: 100)),
                  SizedBox(height: 16),
                  Text(language.createAccount, style: boldTextStyle(size: 22)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Sign up to get started ',
                            style: primaryTextStyle(size: 14)),
                        // TextSpan(text: '🚗', style: primaryTextStyle(size: 20)),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: firstController,
                          focus: firstNameFocus,
                          nextFocus: lastNameFocus,
                          autoFocus: false,
                          textFieldType: TextFieldType.NAME,
                          errorThisFieldRequired: errorThisFieldRequired,
                          decoration: inputDecoration(context,
                              label: language.firstName),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: AppTextField(
                          controller: lastNameController,
                          focus: lastNameFocus,
                          nextFocus: userNameFocus,
                          autoFocus: false,
                          textFieldType: TextFieldType.OTHER,
                          errorThisFieldRequired: errorThisFieldRequired,
                          decoration: inputDecoration(context,
                              label: language.lastName),
                        ),
                      ),
                    ],
                  ),
                  if (widget.socialLogin != true) SizedBox(height: 20),
                  if (widget.socialLogin != true)
                    AppTextField(
                      controller: userNameController,
                      focus: userNameFocus,
                      nextFocus: emailFocus,
                      autoFocus: false,
                      textFieldType: TextFieldType.USERNAME,
                      errorThisFieldRequired: errorThisFieldRequired,
                      decoration:
                          inputDecoration(context, label: language.userName),
                    ),
                  SizedBox(height: 20),
                  AppTextField(
                    controller: emailController,
                    focus: emailFocus,
                    nextFocus: phoneFocus,
                    autoFocus: false,
                    textFieldType: TextFieldType.EMAIL,
                    keyboardType: TextInputType.emailAddress,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: inputDecoration(context, label: language.email),
                  ),
                  if (widget.socialLogin != true) SizedBox(height: 20),
                  if (widget.socialLogin != true)
                    AppTextField(
                      controller: phoneController,
                      textFieldType: TextFieldType.PHONE,
                      focus: phoneFocus,
                      nextFocus: passFocus,
                      decoration: inputDecoration(
                        context,
                        label: language.phoneNumber,
                        prefixIcon: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CountryCodePicker(
                                padding: EdgeInsets.zero,
                                initialSelection: countryCode,
                                showCountryOnly: false,
                                dialogSize: Size(
                                    MediaQuery.of(context).size.width - 60,
                                    MediaQuery.of(context).size.height * 0.6),
                                showFlag: true,
                                showFlagDialog: true,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                textStyle: primaryTextStyle(),
                                dialogBackgroundColor:
                                    Theme.of(context).cardColor,
                                barrierColor: Colors.black12,
                                dialogTextStyle: primaryTextStyle(),
                                searchDecoration: InputDecoration(
                                  iconColor: Theme.of(context).dividerColor,
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).dividerColor)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor)),
                                ),
                                searchStyle: primaryTextStyle(),
                                onInit: (c) {
                                  countryCode = c!.dialCode!;
                                },
                                onChanged: (c) {
                                  countryCode = c.dialCode!;
                                },
                              ),
                              VerticalDivider(
                                  color: Colors.grey.withOpacity(0.5)),
                            ],
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.trim().isEmpty)
                          return errorThisFieldRequired;
                        return null;
                      },
                    ),
                  if (widget.socialLogin != true) SizedBox(height: 20),
                  if (widget.socialLogin != true)
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: passController,
                            focus: passFocus,
                            autoFocus: false,
                            nextFocus: confirmPass,
                            textFieldType: TextFieldType.PASSWORD,
                            errorThisFieldRequired: errorThisFieldRequired,
                            decoration: inputDecoration(context,
                                label: language.password),
                            validator: (String? value) {
                              if (value!.isEmpty) return errorThisFieldRequired;
                              if (value.length < passwordLengthGlobal)
                                return language.passwordLength;
                              return null;
                            },
                          ),
                        ),
                        if (widget.socialLogin != true) SizedBox(width: 16),
                        if (widget.socialLogin != true)
                          Expanded(
                            child: AppTextField(
                              controller: confirmPassController,
                              focus: confirmPass,
                              autoFocus: false,
                              textFieldType: TextFieldType.PASSWORD,
                              errorThisFieldRequired: errorThisFieldRequired,
                              decoration: inputDecoration(context,
                                  label: language.confirmPassword),
                              validator: (String? value) {
                                if (value!.isEmpty)
                                  return errorThisFieldRequired;
                                if (value.length < passwordLengthGlobal)
                                  return language.passwordLength;
                                if (value.trim() != passController.text.trim())
                                  return language.bothPasswordNotMatch;
                                return null;
                              },
                            ),
                          ),
                      ],
                    ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: Checkbox(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeColor: primaryColor,
                          value: isAcceptedTc,
                          shape:
                              RoundedRectangleBorder(borderRadius: radius(4)),
                          onChanged: (v) async {
                            isAcceptedTc = v!;
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${language.iAgreeToThe} ',
                                style: secondaryTextStyle()),
                            TextSpan(
                              text: language.termsConditions,
                              style:
                                  boldTextStyle(color: primaryColor, size: 14),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (widget.termsConditionUrl != null &&
                                      widget.termsConditionUrl!.isNotEmpty) {
                                    launchScreen(
                                        context,
                                        TermsConditionScreen(
                                            title: language.termsConditions,
                                            subtitle: widget.termsConditionUrl),
                                        pageRouteAnimation:
                                            PageRouteAnimation.Slide);
                                  } else {
                                    toast(language.txtURLEmpty);
                                  }
                                },
                            ),
                            TextSpan(text: ' & ', style: secondaryTextStyle()),
                            TextSpan(
                              text: language.privacyPolicy,
                              style:
                                  boldTextStyle(color: primaryColor, size: 14),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (widget.privacyPolicyUrl != null &&
                                      widget.privacyPolicyUrl!.isNotEmpty) {
                                    launchScreen(
                                        context,
                                        TermsConditionScreen(
                                            title: language.privacyPolicy,
                                            subtitle: widget.privacyPolicyUrl),
                                        pageRouteAnimation:
                                            PageRouteAnimation.Slide);
                                  } else {
                                    toast(language.txtURLEmpty);
                                  }
                                },
                            ),
                          ]),
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 32),
                  AppButtonWidget(
                    width: MediaQuery.of(context).size.width,
                    text: language.signUp,
                    onTap: () async {
                      register();
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Positioned(top: context.statusBarHeight + 4, child: BackButton()),
          Observer(builder: (context) {
            return Visibility(
              visible: appStore.isLoading,
              child: loaderWidget(),
            );
          })
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.alreadyHaveAnAccount, style: primaryTextStyle()),
                SizedBox(width: 8),
                inkWellWidget(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(language.logIn,
                      style: boldTextStyle(color: primaryColor)),
                ),
              ],
            ),
          ),
          SizedBox(height: 16)
        ],
      ),
    );
  }
}
