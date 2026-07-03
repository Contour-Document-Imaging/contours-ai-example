package com.contoursai.android.example

import androidx.appcompat.app.AppCompatActivity
import com.contourdocumentimaging.android.contours_ai.ContoursStarterActivity
import com.contourdocumentimaging.android.contours_ai.callback.IContoursResultListener
import com.contourdocumentimaging.android.contours_ai.models.ContoursResultModel

// Encapsulates all direct interaction with the Contour SDK.
class ContourSdkManager {

    // Initializes the SDK once using the shared app configuration.
    fun initialize(activity: AppCompatActivity) {
        ContoursStarterActivity.initialize(activity.applicationContext, ContourSdkConfig.clientId)
    }

    // Starts the SDK for the provided request and forwards callbacks to the caller.
    fun startScan(
        activity: AppCompatActivity,
        scanRequest: ContourSdkConfig.ScanRequest,
        callback: Callback
    ) {
        ContoursStarterActivity.launchSdk(
            activity,
            ContourSdkConfig.createContoursModel(scanRequest),
            ContourSdkConfig.clientId,
            object : IContoursResultListener {
                override fun onCaptureSuccess(contoursResultModel: ContoursResultModel) =
                    callback.onCaptureSuccess(contoursResultModel)

                override fun onEventCapture(eventJsonString: String) = callback.onEvent(eventJsonString)

                override fun onContourClosed() = callback.onClosed()

                override fun onSelfieCaptured(imageCropped: String?) = callback.onSelfieCaptured(imageCropped)
            }
        )
    }

    // Callback bridge used by the activity to receive SDK events.
    interface Callback {
        fun onCaptureSuccess(result: ContoursResultModel)
        fun onEvent(eventJsonString: String)
        fun onClosed()
        fun onSelfieCaptured(imageUri: String?)
    }
}
