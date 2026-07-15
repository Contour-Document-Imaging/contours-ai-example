package com.contoursai.android.example

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.contourdocumentimaging.android.contours_ai.ContoursStarterActivity
import com.contourdocumentimaging.android.contours_ai.callback.IContoursResultListener
import com.contourdocumentimaging.android.contours_ai.constants.ContoursConstants
import com.contourdocumentimaging.android.contours_ai.models.ContoursCapturingMode
import com.contourdocumentimaging.android.contours_ai.models.ContoursEnvironment
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
    private var tvTitle: TextView? = null
    private var tvDescription: TextView? = null
    private var backPreviewTile: View? = null
    private var bitmapFront: Bitmap? = null
    private var bitmapBack: Bitmap? = null
    private var imageName: String? = null

    // Check face controls the capture of front or back check face.
    // It's important to set it correctly because that affects different
    // stages and thresholds of metrics for the process.
    private var checkFace = ContoursConstants.FRONT_FACE

    // Here, we collect SDK events by appending new line char.
    private var docType: ContoursScanType = ContoursScanType.CHECK
    private val tabs = arrayOf(R.id.check, R.id.id, R.id.passport, R.id.selfie)
    private val clientId = "<CLIENT_ID>"

    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        ContoursStarterActivity.initialize(applicationContext, clientId)
        StatusBarUtils.updateStatusBarColor(this)
        bindViews()
        bindClicks()
        selectCheck()
    }

    private fun bindViews() {
        tvTitle = findViewById(R.id.tv_eyebrow)
        tvDescription = findViewById(R.id.tv_screen_description)
        tvFront = findViewById(R.id.tv_front)
        tvBack = findViewById(R.id.tv_back)
        ivFront = findViewById(R.id.iv_front)
        ivBack = findViewById(R.id.iv_back)
        backPreviewTile = findViewById(R.id.back_preview_tile)
        findViewById<TextView>(R.id.tv_version_meta).text = getString(R.string.powered_by_native_android)
    }

    private fun bindClicks() {
        findViewById<View>(R.id.front_preview_tile).setOnClickListener { openContours(true) }
        findViewById<View>(R.id.back_preview_tile).setOnClickListener { openContours(false) }
        findViewById<TextView>(R.id.tv_download_front).setOnClickListener {
            imageName = "Front check contours"
            saveImageToGallery(bitmapFront, imageName)
        }
        findViewById<TextView>(R.id.tv_download_back).setOnClickListener {
            imageName = "Back check contours"
            saveImageToGallery(bitmapBack, imageName)
        }
        findViewById<TextView>(R.id.check).setOnClickListener { selectCheck() }
        findViewById<TextView>(R.id.id).setOnClickListener { selectId() }
        findViewById<TextView>(R.id.passport).setOnClickListener { selectPassport() }
        findViewById<TextView>(R.id.selfie).setOnClickListener { selectSelfie() }
    }

    private fun selectCheck() {
        docType = ContoursScanType.CHECK
        resetView()
        tvTitle?.text = getString(R.string.check_scan)
        tvDescription?.text = getString(R.string.check_description)
        tvFront?.text = getString(R.string.front_check)
        tvBack?.text = getString(R.string.back_check)
        findViewById<TextView>(R.id.tv_download_front).text = getString(R.string.front_check)
        findViewById<TextView>(R.id.tv_download_back).text = getString(R.string.back_check)
        backPreviewTile?.visibility = View.VISIBLE
        handleSelection(R.id.check)
    }

    private fun selectId() {
        docType = ContoursScanType.ID
        resetView()
        tvTitle?.text = getString(R.string.id_scan)
        tvDescription?.text = getString(R.string.id_description)
        tvFront?.text = getString(R.string.front_id)
        tvBack?.text = getString(R.string.back_id)
        findViewById<TextView>(R.id.tv_download_front).text = getString(R.string.front_id)
        findViewById<TextView>(R.id.tv_download_back).text = getString(R.string.back_id)
        backPreviewTile?.visibility = View.VISIBLE
        handleSelection(R.id.id)
    }

    private fun selectPassport() {
        docType = ContoursScanType.PASSPORT
        resetView()
        tvTitle?.text = getString(R.string.passport_scan)
        tvDescription?.text = getString(R.string.passport_description)
        tvFront?.text = getString(R.string.passport_front_face)
        findViewById<TextView>(R.id.tv_download_front).text = getString(R.string.passport_front_face)
        backPreviewTile?.visibility = View.GONE
        handleSelection(R.id.passport)
    }
    private fun selectSelfie() {
        docType = ContoursScanType.SELFIE
        resetView()
        tvTitle?.text = getString(R.string.selfie_scan)
        tvDescription?.text = getString(R.string.selfie_description)
        tvFront?.text = getString(R.string.user_selfie)
        findViewById<TextView>(R.id.tv_download_front).text = getString(R.string.user_selfie)
        backPreviewTile?.visibility = View.GONE
        handleSelection(R.id.selfie)
    }

    /**
     * Opens the SDK for either front or back capture.
     */
    private fun openContours(isFront: Boolean) {
        checkFace = if (isFront) ContoursConstants.FRONT_FACE else ContoursConstants.BACK_FACE
        startScan()
    }

    private fun startScan() {
        val contoursModel = ContoursModel()
        contoursModel.capturingMode = ContoursCapturingMode.BOTH_CAPTURE
        contoursModel.checkFace = when (docType) {
            ContoursScanType.PASSPORT -> ContoursConstants.FRONT_FACE_ONLY
            else -> checkFace
        }
        contoursModel.type = docType
        contoursModel.capturingSide = contoursModel.checkFace
        ContoursStarterActivity.launchSdk(this, contoursModel, clientId, object : IContoursResultListener {
            override fun onCaptureSuccess(contoursResultModel: ContoursResultModel) {
                if (contoursResultModel.resultCheckFace.equals(ContoursConstants.FRONT_FACE, ignoreCase = true)) {
                    showCapturedImage(contoursResultModel.resultFrontCroppedImageUri, ivFront, tvFront, true)
                    showCapturedImage(contoursResultModel.resultRearCroppedImageUri, ivBack, tvBack, false)
                } else if (contoursResultModel.resultCheckFace.equals(ContoursConstants.BACK_FACE, ignoreCase = true)) {
                    showCapturedImage(contoursResultModel.resultRearCroppedImageUri, ivBack, tvBack, false)
                } else if (contoursResultModel.resultCheckFace.equals(ContoursConstants.FRONT_FACE_ONLY, ignoreCase = true)) {
                    showCapturedImage(contoursResultModel.resultFrontCroppedImageUri, ivFront, tvFront, true)
                }
            }

            override fun onEventCapture(eventJsonString: String) {
                println("---------- eventJsonString $eventJsonString")
            }

            override fun onContourClosed() {
                println("---------- SDK closed")
            }

            override fun onSelfieCaptured(imageCropped: String?) {
                showCapturedImage(imageCropped, ivFront, tvFront, true)
            }
        })
    }

    private fun showCapturedImage(imageUri: String?, imageView: ImageView?, textView: TextView?, isFront: Boolean) {
        if (imageUri == null) return
        try {
            val imagePath = URI(imageUri)
            val bitmap = BitmapFactory.decodeFile(imagePath.path, BitmapFactory.Options()) ?: return
            if (isFront) bitmapFront = bitmap else bitmapBack = bitmap
            imageView?.setImageBitmap(bitmap)
            imageView?.visibility = View.VISIBLE
            textView?.visibility = View.GONE
        } catch (e: URISyntaxException) {
            e.printStackTrace()
        }
    }

    private fun saveImageToGallery(bmp: Bitmap?, name: String?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU || hasStoragePermission()) {
            MediaStore.Images.Media.insertImage(contentResolver, bmp, name, "")
            Toast.makeText(this, "Your image has been saved to your gallery", Toast.LENGTH_SHORT).show()
        } else {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), 1004)
        }
    }

    private fun hasStoragePermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1004 && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            if (imageName == "Front check contours") saveImageToGallery(bitmapFront, imageName)
            else saveImageToGallery(bitmapBack, imageName)
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

    private fun getActiveDocumentName(): String {
        return when (docType) {
            ContoursScanType.ID -> "ID"
            ContoursScanType.PASSPORT -> "Passport"
            ContoursScanType.SELFIE -> "Selfie"
            else -> "Check"
        }
    }
}
