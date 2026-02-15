package com.ymrabtipacks.flutter_azimuth

import android.annotation.SuppressLint
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterAzimuthPlugin */
@SuppressLint("NewApi")
class FlutterAzimuthPlugin : FlutterPlugin, MethodCallHandler, SensorEventListener, EventChannel.StreamHandler {

  private lateinit var pluginBinding: FlutterPlugin.FlutterPluginBinding
  private var sensorManager: SensorManager? = null
  private var sensorType: Int = 0
  private var rotationSensor: Sensor? = null
  private var accelerometer: Sensor? = null
  private var magnetometer: Sensor? = null
  private var hasPrimarySensor: Boolean = false
  private var hasSecondarySensor: Boolean = false
  private var eventSink: EventChannel.EventSink? = null
  private var methodChannel: MethodChannel? = null

  private val rotationMatrix = FloatArray(9)
  private val orientation = FloatArray(3)
  private val lastAccelerometer = FloatArray(3)
  private val lastMagnetometer = FloatArray(3)
  private var lastAccelerometerSet = false
  private var lastMagnetometerSet = false
  private var azimuth: Int = 0

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = binding
    methodChannel = MethodChannel(binding.binaryMessenger, "checkDeviceSensors").also {
      it.setMethodCallHandler(this)
    }

    EventChannel(binding.binaryMessenger, "azimuthStream").setStreamHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel?.setMethodCallHandler(null)
    methodChannel = null
    stop()
    eventSink = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getSensors" && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
      result.success(checkSensors())
    } else {
      result.notImplemented()
    }
  }

  @SuppressLint("ServiceCast")
  private fun ensureSensorManager(): SensorManager {
    if (sensorManager == null) {
      sensorManager = pluginBinding.applicationContext.getSystemService(SensorManager::class.java)
    }
    return sensorManager!!
  }

  private fun checkSensors(): Int {
    val manager = ensureSensorManager()
    sensorType = when {
      manager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR) != null -> 2
      manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) != null && manager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD) != null -> 1
      else -> 0
    }
    return sensorType
  }

  override fun onSensorChanged(event: SensorEvent) {
    when (event.sensor.type) {
      Sensor.TYPE_ROTATION_VECTOR -> {
        SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
        azimuth = Math.toDegrees(SensorManager.getOrientation(rotationMatrix, orientation)[0].toDouble()).toInt()
      }

      Sensor.TYPE_ACCELEROMETER -> {
        System.arraycopy(event.values, 0, lastAccelerometer, 0, event.values.size)
        lastAccelerometerSet = true
      }

      Sensor.TYPE_MAGNETIC_FIELD -> {
        System.arraycopy(event.values, 0, lastMagnetometer, 0, event.values.size)
        lastMagnetometerSet = true
      }
    }

    if (lastAccelerometerSet && lastMagnetometerSet) {
      SensorManager.getRotationMatrix(rotationMatrix, null, lastAccelerometer, lastMagnetometer)
      SensorManager.getOrientation(rotationMatrix, orientation)
      azimuth = Math.toDegrees(orientation[0].toDouble()).toInt()
    }

    azimuth = ((azimuth % 360) + 360) % 360

    eventSink?.success(azimuth)
  }

  override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
    // No-op
  }

  private fun resetSensorState() {
    lastAccelerometerSet = false
    lastMagnetometerSet = false
    hasPrimarySensor = false
    hasSecondarySensor = false
  }

  private fun start() {
    val manager = ensureSensorManager()
    if (sensorType == 0) {
      checkSensors()
    }

    resetSensorState()

    when (sensorType) {
      1 -> {
        accelerometer = manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        magnetometer = manager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
        hasPrimarySensor = manager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_UI)
        hasSecondarySensor = manager.registerListener(this, magnetometer, SensorManager.SENSOR_DELAY_UI)
      }

      2 -> {
        rotationSensor = manager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        hasPrimarySensor = manager.registerListener(this, rotationSensor, SensorManager.SENSOR_DELAY_UI)
      }
    }
  }

  private fun stop() {
    val manager = sensorManager ?: return
    if (hasPrimarySensor || hasSecondarySensor) {
      rotationSensor?.let { manager.unregisterListener(this, it) }
      accelerometer?.let { manager.unregisterListener(this, it) }
      magnetometer?.let { manager.unregisterListener(this, it) }
    } else {
      manager.unregisterListener(this)
    }
    resetSensorState()
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
    eventSink = events
    start()
  }

  override fun onCancel(arguments: Any?) {
    stop()
    eventSink = null
  }
}