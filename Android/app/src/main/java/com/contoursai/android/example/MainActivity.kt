package com.contoursai.android.example

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Bundle
import android.os.Build
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.contourdocumentimaging.android.contours_ai.ContoursStarterActivity
import com.contourdocumentimaging.android.contours_ai.callback.IContoursResultListener
import com.contourdocumentimaging.android.contours_ai.constants.ContoursConstants
import com.contourdocumentimaging.android.contours_ai.models.ContoursCapturingMode
import com.contourdocumentimaging.android.contours_ai.models.ContoursModel
import com.contourdocumentimaging.android.contours_ai.models.ContoursResultModel
import com.contourdocumentimaging.android.contours_ai.models.ContoursScanType
import com.contoursai.android.example.utils.StatusBarUtils
import java.net.URI
import java.net.URISyntaxException

class MainActivity : AppCompatActivity() {

    private var ivFront: ImageView? = null
    private var ivBack: ImageView? = null
    private var tvFront: TextView? = null
    private var tvBack: TextView? = null
    private var tvStatus: TextView? = null
    private var tvScreenTitle: TextView? = null
    private var tvScreenDescription: TextView? = null
    private var tvVersionMeta: TextView? = null
    private var tvAppVersion: TextView? = null
    private var frontPreviewTile: View? = null
    private var backPreviewTile: View? = null
    private var bitmapFront: Bitmap? = null
    private var bitmapBack: Bitmap? = null
    private lateinit var gestureDetector: GestureDetector

    // Check face controls the capture of front or back check face.
    // It's important to set it correctly because that affects different
    // stages and thresholds of metrics for the process.
    private var checkFace = ContoursConstants.FRONT_FACE

    private var docType: ContoursScanType = ContoursScanType.CHECK
    private val tabs = arrayOf(R.id.check, R.id.id, R.id.passport, R.id.selfie)
    private val clientId: String = ""

    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        ContoursStarterActivity.initialize(applicationContext, clientId)
        StatusBarUtils.updateStatusBarColor(this)
        tvFront = findViewById<View>(R.id.tv_front) as TextView
        tvBack = findViewById<View>(R.id.tv_back) as TextView
        tvStatus = findViewById(R.id.tv_status)
        tvScreenTitle = findViewById(R.id.tv_screen_title)
        tvScreenDescription = findViewById(R.id.tv_screen_description)
        tvVersionMeta = findViewById(R.id.tv_version_meta)
        tvAppVersion = findViewById(R.id.tv_app_version)
        ivFront = findViewById<View>(R.id.iv_front) as ImageView
        ivBack = findViewById<View>(R.id.iv_back) as ImageView
        frontPreviewTile = findViewById(R.id.front_preview_tile)
        backPreviewTile = findViewById(R.id.back_preview_tile)
        gestureDetector = GestureDetector(this, object : GestureDetector.SimpleOnGestureListener() {
            override fun onDown(e: MotionEvent): Boolean = true

            override fun onFling(
                e1: MotionEvent?,
                e2: MotionEvent,
                velocityX: Float,
                velocityY: Float
            ): Boolean {
                if (e1 == null) return false
                val diffX = e2.x - e1.x
                val diffY = e2.y - e1.y
                if (kotlin.math.abs(diffX) < 120 || kotlin.math.abs(diffX) < kotlin.math.abs(diffY)) {
                    return false
                }

                if (diffX < 0) {
                    switchTab(1)
                } else {
                    switchTab(-1)
                }
                return true
            }
        })
        findViewById<View>(R.id.content_scroll).setOnTouchListener { _, event ->
            gestureDetector.onTouchEvent(event)
            false
        }
        frontPreviewTile!!.setOnClickListener { openContours(true) }
        backPreviewTile!!.setOnClickListener { openContours(false) }
        tvVersionMeta?.text = getString(R.string.powered_by_native_android)
        tvAppVersion?.text = getString(R.string.app_version_format, getAppVersionName())
        findViewById<TextView>(R.id.id).setOnClickListener { selectTab(R.id.id) }
        findViewById<TextView>(R.id.passport).setOnClickListener { selectTab(R.id.passport) }
        findViewById<TextView>(R.id.check).setOnClickListener { selectTab(R.id.check) }
        findViewById<TextView>(R.id.selfie).setOnClickListener { selectTab(R.id.selfie) }
        selectTab(R.id.check)
        setStatus(getString(R.string.preparing_scanner))

    }

    /**
     *
     * @param isFront
     */
    private fun openContours(isFront: Boolean) {
        checkFace = if (isFront) {
            ContoursConstants.FRONT_FACE
        } else {
            ContoursConstants.BACK_FACE
        }
        startScan()
    }

    private fun startScan() {
        setStatus(
            when (docType) {
                ContoursScanType.ID -> "Opening ${if (checkFace == ContoursConstants.FRONT_FACE) "front" else "back"}..."
                ContoursScanType.PASSPORT -> "Opening front face..."
                ContoursScanType.SELFIE -> "Opening face..."
                else -> "Opening ${if (checkFace == ContoursConstants.FRONT_FACE) "front" else "back"}..."
            }
        )
        //Put this code before launching sdk to capture check
        val contoursModel = ContoursModel()
        contoursModel.capturingMode = ContoursCapturingMode.BOTH_CAPTURE
        // checkFace value will be either ContoursConstants.FRONT_FACE of ContoursConstants.BACK_FACE as in openContours() function
        contoursModel.checkFace = checkFace
        contoursModel.type = docType//or ContoursScanType.ID, or ContoursScanType.PASSPORT
        contoursModel.capturingSide = checkFace // or ContoursConstants.BACK_FACE
        ContoursStarterActivity.launchSdk(this, contoursModel, clientId, object: IContoursResultListener{
            override fun onCaptureSuccess(contoursResultModel: ContoursResultModel) {

                if (contoursResultModel.resultCheckFace.equals(ContoursConstants.FRONT_FACE, ignoreCase = true)) {
                    showCapturedImage(contoursResultModel.resultFrontCroppedImageUri, ivFront, tvFront, true)
                    showCapturedImage(contoursResultModel.resultRearCroppedImageUri, ivBack, tvBack, false)
                    setStatus(
                        if (!contoursResultModel.resultRearCroppedImageUri.isNullOrEmpty()) {
                            "${getActiveDocumentName()} front and back scan completed."
                        } else {
                            "${getActiveDocumentName()} front completed."
                        }
                    )
                } else if (contoursResultModel.resultCheckFace.equals(ContoursConstants.BACK_FACE, ignoreCase = true)) {
                    showCapturedImage(contoursResultModel.resultRearCroppedImageUri, ivBack, tvBack, false)
                    setStatus("${getActiveDocumentName()} back scan completed.")
                }  else if (contoursResultModel.resultCheckFace.equals(ContoursConstants.FRONT_FACE_ONLY, ignoreCase = true)) {
                    showCapturedImage(contoursResultModel.resultFrontCroppedImageUri, ivFront, tvFront, true)
                    setStatus("${getActiveDocumentName()} front face completed.")
                }
            }

            override fun onEventCapture(eventJsonString: String) {
                println("---------- eventJsonString $eventJsonString")
            }

            override fun onContourClosed() {
                println("---------- SDK closed")
                if (bitmapFront == null && bitmapBack == null) {
                    setStatus("${getActiveDocumentName()} scan closed.")
                }
            }

            override fun onSelfieCaptured(imageCropped: String?) {
                showCapturedImage(imageCropped, ivFront, tvFront, true)
                setStatus("Selfie completed.")
            }
        })
        //SDK initialization process complete
    }

    private fun showCapturedImage(imageUri: String?, imageView: ImageView?, textView: TextView?, isFront: Boolean) {
        if (imageUri == null) {
            return
        }
        try {
            val backURI = URI(imageUri)
            val options = BitmapFactory.Options()
            val bmp = BitmapFactory.decodeFile(backURI.path, options)
            if (bmp != null) {
                if (isFront) {
                    bitmapFront = bmp
                } else {
                    bitmapBack = bmp
                }
                imageView!!.setImageBitmap(bmp)
                imageView.visibility = View.VISIBLE
                textView!!.visibility = View.GONE
            }
        } catch (e: URISyntaxException) {
            e.printStackTrace()
        }
    }

    private fun resetView() {
        bitmapFront = null
        bitmapBack = null
        tvFront?.visibility = View.VISIBLE
        tvBack?.visibility = View.VISIBLE
        ivFront?.setImageDrawable(null)
        ivBack?.setImageDrawable(null)
        ivFront?.visibility = View.GONE
        ivBack?.visibility = View.GONE
    }

    private fun handleSelection(selectedId: Int) {
        tabs.forEach { id ->
            val textView = findViewById<TextView>(id)
            if (id == selectedId) {
                textView.setBackgroundResource(R.drawable.bg_tab_active)
                textView.setTextColor(Color.WHITE)
            } else {
                textView.background = null
                textView.setTextColor(ContextCompat.getColor(this, R.color.text_muted))
            }
        }
    }

    private fun selectTab(selectedId: Int) {
        resetView()
        when (selectedId) {
            R.id.id -> {
                docType = ContoursScanType.ID
                updateDocumentUi(
                    title = R.string.id_scan,
                    description = R.string.id_description,
                    frontLabel = R.string.front_id,
                    backLabel = R.string.back_id,
                    showBack = true
                )
            }
            R.id.passport -> {
                docType = ContoursScanType.PASSPORT
                updateDocumentUi(
                    title = R.string.passport_scan,
                    description = R.string.passport_description,
                    frontLabel = R.string.passport_front_face,
                    backLabel = null,
                    showBack = false
                )
            }
            R.id.selfie -> {
                docType = ContoursScanType.SELFIE
                updateDocumentUi(
                    title = R.string.selfie_scan,
                    description = R.string.selfie_description,
                    frontLabel = R.string.user_selfie,
                    backLabel = null,
                    showBack = false
                )
            }
            else -> {
                docType = ContoursScanType.CHECK
                updateDocumentUi(
                    title = R.string.check_scan,
                    description = R.string.check_description,
                    frontLabel = R.string.front_check,
                    backLabel = R.string.back_check,
                    showBack = true
                )
            }
        }
        handleSelection(selectedId)
    }

    private fun switchTab(direction: Int) {
        val currentIndex = tabs.indexOfFirst { isTabSelected(it) }.coerceAtLeast(0)
        val nextIndex = (currentIndex + direction).coerceIn(0, tabs.lastIndex)
        if (nextIndex != currentIndex) {
            selectTab(tabs[nextIndex])
        }
    }

    private fun isTabSelected(tabId: Int): Boolean {
        return findViewById<TextView>(tabId).currentTextColor == Color.WHITE
    }

    private fun updateDocumentUi(
        title: Int,
        description: Int,
        frontLabel: Int,
        backLabel: Int?,
        showBack: Boolean
    ) {
        tvScreenTitle?.text = getString(title)
        tvScreenDescription?.text = getString(description)
        tvFront?.text = getString(frontLabel)
        findViewById<TextView>(R.id.tv_download_front).text = getString(frontLabel)

        if (backLabel != null) {
            tvBack?.text = getString(backLabel)
            findViewById<TextView>(R.id.tv_download_back).text = getString(backLabel)
        }

        updatePreviewLayout(showBack)
        setStatus("Ready to scan ${getActiveDocumentName().lowercase()}.")
    }

    private fun updatePreviewLayout(showBack: Boolean) {
        backPreviewTile?.visibility = if (showBack) View.VISIBLE else View.GONE
    }

    private fun getActiveDocumentName(): String {
        return when (docType) {
            ContoursScanType.ID -> "ID"
            ContoursScanType.PASSPORT -> "Passport"
            ContoursScanType.SELFIE -> "Selfie"
            else -> "Check"
        }
    }

    private fun setStatus(message: String) {
        tvStatus?.text = message
    }

    private fun getAppVersionName(): String {
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(packageName, android.content.pm.PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(packageName, 0)
        }

        return packageInfo.versionName ?: "1.0"
    }
}
