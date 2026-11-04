import 'package:bot_toast/bot_toast.dart';
import 'package:cm_tour/utils/fade_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FontFamily {
  FontFamily._();

  static const String promptRegular = 'Prompt-Regular';
}

class ToolUtility {
  static const String appName = '24Travelling';

  static String yyyyMMddDash = 'yyyy-MM-dd';
  static String ddMMyyyy = 'dd/MM/yyyy';
  static String yyyyMMddDashHHmmss = 'yyyy-MM-dd HH:mm:ss';
  static String showTimeOnly = 'HH:mm';

  static String convertDateString(
    String date,
    String fromFormat,
    String toFormat,
  ) {
    if (stringIsNullOrEmpty(date)) return '';
    return DateFormat(toFormat).format(DateFormat(fromFormat).parse(date.trim()));
  }

  static String convertTimeString(
    String time,
    String fromFormat,
    String toFormat,
  ) {
    if (stringIsNullOrEmpty(time)) return '';
    return DateFormat(toFormat).format(DateFormat(fromFormat).parse(time.trim()));
  }

  static String fontPromptRegular = FontFamily.promptRegular;

  static const int colorMainHax = 0xFFF36B21;
  static const Color colorMain = Color(colorMainHax);
  static const Color colorMainDark = Color(0xFFD35400);
  static const Color colorCart = Color(0xFFFFF1E8);
  static const Color colorAccent = Color(colorMainHax);
  static const Color colorRetry = Color(0xFFE15B4C);
  static const Color colorPage = Color(0xFFF4F6F8);

  static Map<int, Color> colorMainPrimarySwatch = {
    50: colorMain,
    100: colorMain,
    200: colorMain,
    300: colorMain,
    400: colorMain,
    500: colorMain,
    600: colorMain,
    700: colorMain,
    800: colorMain,
    900: colorMain,
  };

  static const Duration timeout = Duration(seconds: 30);

  static double fontSizeNormal = 14;
  static double fontSizeNormal1 = 16;
  static double fontSizeButton2 = 12;
  static double fontSizeButton = 18;
  static double fontSizeShowInformation = 10;
  static double fontSize16px = 14;
  static double fontSize14px = 12;
  static double fontSizeIconDashboard = 40;
  static double borderRadiusNormal = 5;
  static double fontSizeToast = 16;
  static double buttonBorderRadius = 8;

  static FilteringTextInputFormatter textInputAllowTypeText =
      FilteringTextInputFormatter.allow(
    RegExp(r"[a-zA-Zก-ฮฯะัาำิีึืฺุูเแโใไๅๆ็่้๊๋์0-9-.@ ]"),
  );
  static const TextInputType textInputTypeText = TextInputType.text;
  static const TextInputType textInputTypeNumber = TextInputType.number;

  static const Color colorWhite = Colors.white;
  static const Color colorBlack = Colors.black;
  static const Color colorGrey = Colors.grey;
  static const Color colorGreen = Colors.green;
  static const Color colorTransparent = Colors.transparent;
  static const Color colorGreyCustom1 = Color.fromRGBO(51, 51, 51, 0.8);
  static const Color colorGreyCustom2 = Color.fromRGBO(224, 224, 224, 1);
  static const Color colorGreyCustom3 = Color.fromRGBO(242, 242, 242, 1);
  static const Color colorGreyCustom4 = Color.fromRGBO(189, 189, 189, 1);
  static const Color colorGreyCustom6 = Color.fromRGBO(106, 106, 106, 1);
  static const Color colorGreyCustom7 = Color.fromRGBO(128, 128, 128, 1);
  static const Color colorGreyCustom10 = Color.fromRGBO(244, 244, 244, 1);
  static const Color colorWaitForApproved = Color.fromRGBO(251, 191, 36, 1);
  static const Color colorApproved = Color.fromRGBO(22, 163, 74, 1);
  static const Color colorReject = Color.fromRGBO(220, 38, 38, 1);

  static const IconData iconHistory = FontAwesomeIcons.clockRotateLeft;
  static const IconData iconSearch = FontAwesomeIcons.magnifyingGlass;
  static const IconData iconTrash = FontAwesomeIcons.trash;
  static const IconData iconSave = Icons.save;
  static const IconData iconAdd = FontAwesomeIcons.circlePlus;
  static const IconData iconAdd2 = FontAwesomeIcons.plus;
  static const IconData iconOK = FontAwesomeIcons.solidCircleCheck;
  static const IconData iconCheck = FontAwesomeIcons.check;
  static const IconData iconClose = FontAwesomeIcons.solidCircleXmark;
  static const IconData iconClose2 = FontAwesomeIcons.xmark;

  static final RegExp regExpEmail = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static TextStyle prompt(
    double size, {
    FontWeight weight = FontWeight.normal,
    Color color = colorBlack,
  }) {
    return TextStyle(
      fontFamily: fontPromptRegular,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static Widget showText(
    BuildContext context,
    String text,
    FontWeight weightText,
    Color textColor,
    double fontSize,
  ) {
    return Text(
      text,
      style: prompt(
        autoSize(context, fontSize),
        weight: weightText,
        color: textColor,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  static Future<void> loading(bool isShow) async {
    if (isShow) {
      BotToast.showLoading(
        backButtonBehavior: BackButtonBehavior.ignore,
        backgroundColor: colorTransparent,
      );
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
    BotToast.closeAllLoading();
  }

  static bool checkEmailFormat(String email) => regExpEmail.hasMatch(email);

  static Radius borderRadiusNormalCircular(BuildContext context) {
    return Radius.circular(autoSize(context, borderRadiusNormal));
  }

  static BorderRadius borderRadiusNormalAllCircular(BuildContext context) {
    return BorderRadius.circular(autoSize(context, borderRadiusNormal));
  }

  static bool stringIsNullOrEmpty(dynamic data) {
    return ['', 'null', null].contains(data);
  }

  static bool isNumberZero(dynamic data) {
    return ['0', '0.0', 0, 0.0].contains(data);
  }

  static OutlineInputBorder borderInput(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(autoSize(context, 5))),
    );
  }

  static Widget dividerList(BuildContext context, double lineHeight) {
    return Column(
      children: [
        Divider(
          color: colorMain,
          indent: autoSize(context, 5),
          endIndent: autoSize(context, 5),
          thickness: autoSize(context, lineHeight),
        ),
      ],
    );
  }

  static Widget loadingSearch(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(autoSize(context, 10)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorMain),
          ),
        ],
      ),
    );
  }

  static void toast(BuildContext context, bool isSuccess, String msg) {
    BotToast.showText(
      text: msg,
      contentColor: isSuccess ? colorGreen : Colors.brown,
      animationDuration: const Duration(milliseconds: 500),
      duration: const Duration(seconds: 4),
      textStyle: prompt(autoSize(context, fontSizeToast), color: colorWhite),
    );
  }

  static void gotoPage(BuildContext? context, Widget page) {
    if (context == null) return;
    Navigator.of(context).pushAndRemoveUntil(
      FadeScreen(page: page),
      (Route<dynamic> route) => false,
    );
  }

  static void gotoPageHasBack(BuildContext context, Widget page) {
    Navigator.push(context, FadeScreen(page: page));
  }

  static void gotoPageFromFCM(Widget page) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      FadeScreen(page: page),
      (Route<dynamic> route) => false,
    );
  }

  static double autoSize(BuildContext context, double size) {
    final width = MediaQuery.sizeOf(context).width;
    final factor = MediaQuery.textScalerOf(context).scale(1);
    final base = width * (0.0025 * size);
    if (factor <= 1) return base;
    return base / factor;
  }

  static String money(num value) {
    return NumberFormat('#,##0', 'th').format(value);
  }
}
