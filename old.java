package com.ymrabtipacks.flutter_azimuth;

import androidx.annotation.NonNull;
import android.annotation.SuppressLint;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

import io.flutter.plugin.common.EventChannel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.content.Context.SENSOR_SERVICE;
/** FlutterAzimuthPlugin */
public class FlutterAzimuthPlugin implements FlutterPlugin, MethodCallHandler, SensorEventListener, EventChannel.StreamHandler {

  private Registrar mRegistrar;
  int mAzimuth;
  int previousAz=0;
  private int sensorType;
  private boolean haveSensor = false, haveSensor2 = false;
  private SensorManager mSensorManager;
  private Sensor mRotationV, mAccelerometer, mMagnetometer;
  float[] rMat = new float[9];
  float[] orientation = new float[3];
  private float[] mLastAccelerometer = new float[3];
  private float[] mLastMagnetometer = new float[3];
  private boolean mLastAccelerometerSet = false;
  private boolean mLastMagnetometerSet = false;
  private EventChannel.EventSink mEventSink;

  private MethodChannel channel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {

    FlutterAzimuthPlugin plugin = new FlutterAzimuthPlugin(registrar);

    final MethodChannel channel = new MethodChannel(registrar.messenger(), "checkDeviceSensors");
    channel.setMethodCallHandler(plugin);

    final EventChannel eventChannel = new EventChannel(registrar.messenger(),"azimuthStream");
    eventChannel.setStreamHandler(plugin);

  }

  FlutterAzimuthPlugin(Registrar registrar) {mRegistrar = registrar;}

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getSensors")) {
      sensorType = checkSensors();
      result.success(sensorType);
    } else {
      result.notImplemented();
    }
  }

  
  private int checkSensors() {
    mSensorManager = (SensorManager) (mRegistrar.activeContext().getSystemService(SENSOR_SERVICE));
    if (mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR) == null) {
      if ((mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) == null) || (mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD) == null)) {
        return 0;
      } else {
        return 1;
      }
    } else {
      return 2;
    }

  }


  
  @Override
  public void onSensorChanged(SensorEvent event) {
    if (event.sensor.getType() == Sensor.TYPE_ROTATION_VECTOR) {
      SensorManager.getRotationMatrixFromVector(rMat, event.values);
      mAzimuth = (int) (Math.toDegrees(SensorManager.getOrientation(rMat, orientation)[0]) + 360) % 360;
    }

    if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
      System.arraycopy(event.values, 0, mLastAccelerometer, 0, event.values.length);
      mLastAccelerometerSet = true;
    } else if (event.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD) {
      System.arraycopy(event.values, 0, mLastMagnetometer, 0, event.values.length);
      mLastMagnetometerSet = true;
    }
    if (mLastAccelerometerSet && mLastMagnetometerSet) {
      SensorManager.getRotationMatrix(rMat, null, mLastAccelerometer, mLastMagnetometer);
      SensorManager.getOrientation(rMat, orientation);
      mAzimuth = (int) (Math.toDegrees(SensorManager.getOrientation(rMat, orientation)[0]) + 360) % 360;
    }

    mAzimuth = Math.round(mAzimuth);

    if(mEventSink!=null)
      mEventSink.success(mAzimuth);

    previousAz = mAzimuth;

  }

  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {

  }

  
  public void start() {

    if (sensorType==1) {

      mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
      mMagnetometer = mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
      haveSensor = mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_UI);
      haveSensor2 = mSensorManager.registerListener(this, mMagnetometer, SensorManager.SENSOR_DELAY_UI);

    }
    else
    if(sensorType==2){
      mRotationV = mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
      haveSensor = mSensorManager.registerListener(this, mRotationV, SensorManager.SENSOR_DELAY_UI);
    }
  }

  
  public void stop() {
    if (haveSensor) {
      mSensorManager.unregisterListener(this, mRotationV);
    }
    else {
      mSensorManager.unregisterListener(this, mAccelerometer);
      mSensorManager.unregisterListener(this, mMagnetometer);
    }
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    mEventSink = eventSink;
    start();
  }

  @Override
  public void onCancel(Object o) {
    stop();
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_azimuth");
    channel.setMethodCallHandler(this);
  }
  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }



}
