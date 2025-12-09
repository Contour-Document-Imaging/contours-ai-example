package com.contoursai.android.example

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import android.widget.Toast
import androidx.core.app.ActivityCompat
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
    private var bitmapFront: Bitmap? = null
    private var bitmapBack: Bitmap? = null
    private var imageName: String? = null

    // Check face controls the capture of front or back check face.
    // It's important to set it correctly because that affects different
    // stages and thresholds of metrics for the process.
    private var checkFace = ContoursConstants.FRONT_FACE

    //Here, We will collect all events by appending new line char
    private var events: String = "";
    private var docType: ContoursScanType = ContoursScanType.CHECK

    private val clientId: String = ""

    public override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        ContoursStarterActivity.initialize(applicationContext, clientId)
        StatusBarUtils.updateStatusBarColor(this)
        tvFront = findViewById<View>(R.id.tvFront) as TextView
        tvBack = findViewById<View>(R.id.tvBack) as TextView
        ivFront = findViewById<View>(R.id.ivFront) as ImageView
        ivBack = findViewById<View>(R.id.ivBack) as ImageView
        ivFront!!.setOnClickListener { openContours(true) }
        ivBack!!.setOnClickListener { openContours(false) }
        (findViewById<View>(R.id.tvDownloadFront) as TextView).setOnClickListener {
            imageName = "Front check contours"
            saveImageToGallery(bitmapFront, imageName)
        }
        (findViewById<View>(R.id.tvDownloadBack) as TextView).setOnClickListener {
            imageName = "Back check contours"
            saveImageToGallery(bitmapBack, imageName)
        }
        findViewById<TextView>(R.id.id).setOnClickListener {
            docType = ContoursScanType.ID
            resetView()
            tvFront?.text = getString(R.string.front_id)
            tvBack?.text = getString(R.string.back_id)
            findViewById<RelativeLayout>(R.id.layoutBack).visibility = View.VISIBLE
        }
        findViewById<TextView>(R.id.passport).setOnClickListener {
            docType = ContoursScanType.PASSPORT
            tvFront?.text = getString(R.string.passport)
            resetView()
            findViewById<RelativeLayout>(R.id.layoutBack).visibility = View.INVISIBLE
        }
        findViewById<TextView>(R.id.check).setOnClickListener {
            docType = ContoursScanType.CHECK
            resetView()
            tvFront?.text = getString(R.string.front_check)
            tvBack?.text = getString(R.string.back_check)
            findViewById<RelativeLayout>(R.id.layoutBack).visibility = View.VISIBLE
        }

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
        events = ""
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
                    (findViewById<View>(R.id.tvDownloadFront) as TextView).visibility = if (contoursResultModel.resultFrontCroppedImageUri != null && contoursResultModel.resultFrontCroppedImageUri.isNotEmpty()) View.VISIBLE else View.GONE
                    //Below keys contains full captured image for front and back face which is to be sent to server
                    //contoursResultModel.resultFrontImageUri
                    //contoursResultModel.resultRearImageUri
                    showCapturedImage(contoursResultModel.resultFrontCroppedImageUri, ivFront, tvFront, true)
                    showCapturedImage(contoursResultModel.resultRearCroppedImageUri, ivBack, tvBack, false)
                } else if (contoursResultModel.resultCheckFace.equals(ContoursConstants.BACK_FACE, ignoreCase = true)) {
                    (findViewById<View>(R.id.tvDownloadBack) as TextView).visibility = if (contoursResultModel.resultRearCroppedImageUri != null && contoursResultModel.resultRearCroppedImageUri.isNotEmpty()) View.VISIBLE else View.GONE
                    showCapturedImage(contoursResultModel.resultRearCroppedImageUri, ivBack, tvBack, false)
                }  else if (contoursResultModel.resultCheckFace.equals(ContoursConstants.FRONT_FACE_ONLY, ignoreCase = true)) {
                    (findViewById<View>(R.id.tvDownloadBack) as TextView).visibility = if (contoursResultModel.resultRearCroppedImageUri != null && contoursResultModel.resultRearCroppedImageUri.isNotEmpty()) View.VISIBLE else View.GONE
                    showCapturedImage(contoursResultModel.resultFrontCroppedImageUri, ivFront, tvFront, true)
                }
            }

            override fun onEventCapture(eventJsonString: String) {
                println("---------- eventJsonString $eventJsonString")
                events += "$eventJsonString\n\n"
            }

            override fun onContourClosed() {
                println("---------- SDK closed")
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
                textView!!.visibility = View.GONE
            }
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
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1004 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            if (imageName != null && imageName == "Front check contours") {
                saveImageToGallery(bitmapFront, imageName)
            } else {
                saveImageToGallery(bitmapBack, imageName)
            }
        }
    }

    private fun resetView() {
        tvFront?.visibility = View.VISIBLE
        tvBack?.visibility = View.VISIBLE
        ivFront?.setImageResource(android.R.color.transparent)
        ivBack?.setImageResource(android.R.color.transparent)
        findViewById<View>(R.id.tvDownloadFront).visibility = View.INVISIBLE
        findViewById<View>(R.id.tvDownloadBack).visibility = View.INVISIBLE
    }

    companion object {
        private const val TAG = "ContoursDemo::MainActivity"
    }
}