import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const IS_SHOW_BUTTONS = 'IS_SHOW_BUTTONS';
const APP_LINK = 'APP_LINK';

class Config {
  Future<RemoteConfig> setupRemoteConfig() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));
    remoteConfig.setDefaults(<String, dynamic>{
      IS_SHOW_BUTTONS: 1,
      APP_LINK: "",
    });

    try {
      // Using default duration to force fetching from remote server.
      print('RemoteConfig: fetching...');
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));

      print('RemoteConfig: activated...');
      await remoteConfig.activateFetched();
      remoteConfig.notifyListeners();
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print('RemoteConfig: fetch failed...$exception');
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }

    print('RemoteConfig: isVisible >> ' +
        remoteConfig.getString(IS_SHOW_BUTTONS));
    setAppVisible(int.parse(remoteConfig.getString(IS_SHOW_BUTTONS)));

    print('RemoteConfig: Link >> ' + remoteConfig.getString(APP_LINK));
    setAppLink(remoteConfig.getString(APP_LINK));

    ///----------- Get value back----------
    isAppVisible().then((visible) {
      print('RemoteConfig: saved config...$visible');
    });

    getAppLink().then((link) {
      print('RemoteConfig: saved link...$link');
    });

    return remoteConfig;
  }
}

Future<void> setAppVisible(int visible) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(IS_SHOW_BUTTONS, visible);
  print('Saved app visible....$visible');
}

Future<int> isAppVisible() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(IS_SHOW_BUTTONS) != null
      ? prefs.getInt(IS_SHOW_BUTTONS)
      : 0;
}

Future<void> setAppLink(String link) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(APP_LINK, link);
  print('Saved app link....$link');
}

Future<String> getAppLink() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(APP_LINK) != null ? prefs.getString(APP_LINK) : "";
}

launchURL(String link) async {
  if (await canLaunch(link)) {
    await launch(link);
  } else {
    throw 'Could not launch $link';
  }
}
