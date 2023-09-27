package com.kuriotetsuya.xprinter.print.image.plugin.xprinter_print_image_plugin

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import net.posprinter.IDeviceConnection
import net.posprinter.POSConnect
import net.posprinter.POSPrinter
import net.posprinter.POSConst

/** XprinterPrintImagePlugin */
class XprinterPrintImagePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var printer: POSPrinter
    private var curConnect: IDeviceConnection? = null
    private var context: Context? = null
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        onAttachedToEngine(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger
        );
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.e("CALL METHOD", "---- \t" + call.method)
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "connectDevice" -> {

                Log.e("MAC ADDRESS", "---- \t" + call.argument("macAddress"))
                POSConnect.init(context)
                curConnect = POSConnect.createDevice(POSConnect.DEVICE_TYPE_BLUETOOTH)

                val macAddress = call.argument<String>("macAddress")
                curConnect?.connect(macAddress) { code, message ->
                    when (code) {
                        POSConnect.CONNECT_SUCCESS -> {
                            Log.e(
                                "PRINTER STATUS",
                                "CONNECT SUCCESS$code $message"
                            )
                            result.success(code)

                        }

                        POSConnect.CONNECT_FAIL -> {
                            Log.e(
                                "PRINTER STATUS",
                                "CONNECT FAILED $code $message"
                            )

                        }

                        POSConnect.SEND_FAIL -> {
                            Log.e(
                                "PRINTER STATUS",
                                "SEND FAILED $code $message"
                            )
                        }
                    }
                }
                printer = POSPrinter(curConnect)
            }

            "disconnectDevice" -> {
                curConnect?.let {
                    if (it.isConnect)
                        it.close()
                }
            }

            "printImage" -> {
                val printBmp = call.argument<String>("bitmap")
                printer!!.printBitmap(printBmp, POSConst.ALIGNMENT_CENTER, 384)
                    .feedLine()
                    .cutHalfAndFeed(1)
            }

            else -> result.notImplemented()
        }

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = null
    }

    private fun onAttachedToEngine(applicationContext: Context, messenger: BinaryMessenger) {
        this.context = applicationContext
        val methodChannel = MethodChannel(messenger, "xprinter_print_image_plugin")
        val eventChannel = EventChannel(messenger, "xprinter_print_image_plugin/print_image")
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                setSink(events)
            }

            override fun onCancel(arguments: Any?) {
            }
        })
    }

    companion object {
        private var sink: EventChannel.EventSink? = null

        fun setSink(eventSink: EventChannel.EventSink?) {
            sink = eventSink
        }

        fun printStatus(status: String) {
            val map: HashMap<String, Any> = HashMap()
            map["status"] = status
            sink?.success(map)
        }

        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val instance = XprinterPrintImagePlugin()
            instance.onAttachedToEngine(registrar.context(), registrar.messenger())
        }
    }
}
