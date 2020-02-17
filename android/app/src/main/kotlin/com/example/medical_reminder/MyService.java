package com.example.medical_reminder;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.AudioAttributes;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.IBinder;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.squareup.seismic.ShakeDetector;

public class MyService extends Service implements ShakeDetector.Listener {

    private SensorManager sensorMgr;
    @Override
    public void onCreate() {
        super.onCreate();


        sensorMgr = (SensorManager) getSystemService(SENSOR_SERVICE);
        ShakeDetector sd = new ShakeDetector(this);
        sd.start(sensorMgr);

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "messages")
                    .setContentText("App is running in background")
                    .setContentTitle("Lifement Emergency")
                    .setSmallIcon(R.drawable.app_icon);

            startForeground(101, builder.build());
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void hearShake() {

        if(MainActivity.Companion.getMIsServiceRunning()){
            Context ctx = this; // or you can replace **'this'** with your **ActivityName.this**
            try {
                Intent i = ctx.getPackageManager().getLaunchIntentForPackage("com.example.medical_reminder");
                ctx.startActivity(i);
            } catch (Exception e) {
                e.printStackTrace();
                // TODO Auto-generated catch block
            }
            Uri sound = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://"+ getApplicationContext().getPackageName() + "/" + R.raw.notification_sound);

            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "messages")
                    .setContentTitle("Warning: Emergency Case!!")
                    .setContentText("The device is shaked abnormally. click to open app and ask for help from the emergency page.")
                    .setSmallIcon(R.drawable.app_icon)
                    .setSound(sound)
                    .setColorized(true)
                    .setAutoCancel(true)
                    .setOngoing(false);

            Intent toLaunch = new Intent(this, MainActivity.class);
            toLaunch.putExtra("payload", "emergency");

            PendingIntent contentIntent = PendingIntent.getActivity(this, 12345,
                    toLaunch, PendingIntent.FLAG_UPDATE_CURRENT);


            builder.setContentIntent(contentIntent);

            // Gets an instance of the NotificationManager service
            NotificationManager mNotificationManager =
                    (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);

            Notification notification = builder.build();
            //notification.sound = sound;
            // Builds the notification and issues it.
            mNotificationManager.notify(500, notification);
            MainActivity.Companion.setMIsNotificationSent(true);
        }

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}
