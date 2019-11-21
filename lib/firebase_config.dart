import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

const KEY_VISIBLE_LINK = 'KEY_VISIBLE_LINK';
const APP_LINK = 'APP_LINK';

class Config {
  Future<RemoteConfig> setupRemoteConfig() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));
    remoteConfig.setDefaults(<String, dynamic>{
      KEY_VISIBLE_LINK: 1,
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
        remoteConfig.getString(KEY_VISIBLE_LINK));
    setAppVisible(int.parse(remoteConfig.getString(KEY_VISIBLE_LINK)));

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
  await prefs.setInt(KEY_VISIBLE_LINK, visible);
  print('Saved app visible....$visible');
}

Future<int> isAppVisible() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(KEY_VISIBLE_LINK) != null
      ? prefs.getInt(KEY_VISIBLE_LINK)
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
