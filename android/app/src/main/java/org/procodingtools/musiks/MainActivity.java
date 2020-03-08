package org.procodingtools.musiks;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if(intent.getAction().equals("org.procodingtools.musiks.finish"))
                finish();
        }
    };

    @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

        IntentFilter filter = new IntentFilter();
        filter.addAction("org.procodingtools.musiks.finish");

        registerReceiver(receiver, filter);

      new MethodChannel(getFlutterView(), "android_app_retain").setMethodCallHandler((call, result) -> {
          if (call.method.equals("sendToBackground")) {
              moveTaskToBack(true);
          }
      });
  }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(receiver);
    }
}
