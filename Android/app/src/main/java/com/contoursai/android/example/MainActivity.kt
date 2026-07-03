package com.contoursai.android.example

import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import com.contoursai.android.example.utils.StatusBarUtils
import java.net.URI
import java.net.URISyntaxException
import kotlin.math.abs

// Renders UI and forwards user actions to the ViewModel and SDK manager.
class MainActivity : AppCompatActivity(), ContourSdkManager.Callback {

    private lateinit var viewModel: MainViewModel
    private val sdkManager = ContourSdkManager()

    private lateinit var ivFront: ImageView
    private lateinit var ivBack: ImageView
    private lateinit var tvFront: TextView
    private lateinit var tvBack: TextView
    private lateinit var tvEyebrow: TextView
    private lateinit var tvStatus: TextView
    private lateinit var tvScreenTitle: TextView
    private lateinit var tvScreenDescription: TextView
    private lateinit var tvVersionMeta: TextView
    private lateinit var tvAppVersion: TextView
    private lateinit var tvDownloadFront: TextView
    private lateinit var tvDownloadBack: TextView
    private lateinit var frontPreviewTile: View
    private lateinit var backPreviewTile: View
    private lateinit var contentScroll: View
    private lateinit var gestureDetector: GestureDetector

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        StatusBarUtils.updateStatusBarColor(this)
        sdkManager.initialize(this)
        viewModel = ViewModelProvider(this)[MainViewModel::class.java]
        bindViews()
        setupGestures()
        setupTabs()
        setupPreviewClicks()
        renderStaticMeta()
        observeUiState()
        if (savedInstanceState == null) viewModel.selectTab(ContourSdkConfig.defaultTabId)
    }

    // Binds all XML views once so the activity only renders state.
    private fun bindViews() {
        tvEyebrow = findViewById(R.id.tv_eyebrow)
        tvFront = findViewById(R.id.tv_front)
        tvBack = findViewById(R.id.tv_back)
        tvStatus = findViewById(R.id.tv_status)
        tvScreenTitle = findViewById(R.id.tv_screen_title)
        tvScreenDescription = findViewById(R.id.tv_screen_description)
        tvVersionMeta = findViewById(R.id.tv_version_meta)
        tvAppVersion = findViewById(R.id.tv_app_version)
        tvDownloadFront = findViewById(R.id.tv_download_front)
        tvDownloadBack = findViewById(R.id.tv_download_back)
        ivFront = findViewById(R.id.iv_front)
        ivBack = findViewById(R.id.iv_back)
        frontPreviewTile = findViewById(R.id.front_preview_tile)
        backPreviewTile = findViewById(R.id.back_preview_tile)
        contentScroll = findViewById(R.id.content_scroll)
    }

    // Observes the ViewModel state and redraws the screen when it changes.
    private fun observeUiState() {
        viewModel.uiState.observe(this) { renderState(it) }
    }

    // Configures horizontal swipe navigation between tabs.
    private fun setupGestures() {
        gestureDetector = GestureDetector(this, object : GestureDetector.SimpleOnGestureListener() {
            override fun onDown(e: MotionEvent) = true

            override fun onFling(e1: MotionEvent?, e2: MotionEvent, velocityX: Float, velocityY: Float): Boolean {
                if (e1 == null) return false
                val diffX = e2.x - e1.x
                val diffY = e2.y - e1.y
                if (abs(diffX) < 120 || abs(diffX) < abs(diffY)) return false
                viewModel.moveTab(if (diffX < 0) 1 else -1)
                return true
            }
        })
        contentScroll.setOnTouchListener { _, event -> gestureDetector.onTouchEvent(event); false }
    }

    // Connects bottom tab clicks to the ViewModel.
    private fun setupTabs() {
        findViewById<TextView>(R.id.check).setOnClickListener { viewModel.selectTab(R.id.check) }
        findViewById<TextView>(R.id.id).setOnClickListener { viewModel.selectTab(R.id.id) }
        findViewById<TextView>(R.id.passport).setOnClickListener { viewModel.selectTab(R.id.passport) }
        findViewById<TextView>(R.id.selfie).setOnClickListener { viewModel.selectTab(R.id.selfie) }
    }

    // Starts front or back scan requests based on the tapped preview tile.
    private fun setupPreviewClicks() {
        frontPreviewTile.setOnClickListener { sdkManager.startScan(this, viewModel.prepareScan(true), this) }
        backPreviewTile.setOnClickListener { sdkManager.startScan(this, viewModel.prepareScan(false), this) }
    }

    // Renders static header metadata that does not belong to UI state.
    private fun renderStaticMeta() {
        tvVersionMeta.text = getString(R.string.powered_by_native_android)
        tvAppVersion.text = getString(R.string.app_version_format, getAppVersionName())
    }

    // Applies the full screen state produced by the ViewModel.
    private fun renderState(state: MainUiState) {
        tvEyebrow.text = getString(state.titleRes)
        tvScreenTitle.text = getString(state.titleRes)
        tvScreenDescription.text = getString(state.descriptionRes)
        tvFront.text = getString(state.frontLabelRes)
        tvDownloadFront.text = getString(state.frontLabelRes)
        state.backLabelRes?.let {
            tvBack.text = getString(it)
            tvDownloadBack.text = getString(it)
        }
        tvStatus.text = state.statusText
        backPreviewTile.visibility = if (state.showBackPreview) View.VISIBLE else View.GONE
        renderTabSelection(state.selectedTabId)
        renderPreview(state.frontImageUri, ivFront, tvFront)
        renderPreview(state.backImageUri, ivBack, tvBack)
    }

    // Highlights the active tab and resets the inactive tabs.
    private fun renderTabSelection(selectedTabId: Int) {
        listOf(R.id.check, R.id.id, R.id.passport, R.id.selfie).forEach { id ->
            findViewById<TextView>(id).apply {
                if (id == selectedTabId) {
                    setBackgroundResource(R.drawable.bg_tab_active)
                    setTextColor(Color.WHITE)
                } else {
                    background = null
                    setTextColor(ContextCompat.getColor(context, R.color.text_muted))
                }
            }
        }
    }

    // Shows either the empty placeholder or the captured preview image.
    private fun renderPreview(imageUri: String?, imageView: ImageView, textView: TextView) {
        val bitmap = decodeBitmap(imageUri)
        imageView.setImageBitmap(bitmap)
        imageView.visibility = if (bitmap != null) View.VISIBLE else View.GONE
        textView.visibility = if (bitmap != null) View.GONE else View.VISIBLE
    }

    // Converts the SDK file URI into a Bitmap for preview rendering.
    private fun decodeBitmap(imageUri: String?): Bitmap? {
        if (imageUri == null) return null
        return try {
            BitmapFactory.decodeFile(URI(imageUri).path, BitmapFactory.Options())
        } catch (error: URISyntaxException) {
            error.printStackTrace()
            null
        }
    }

    // Reads the installed app version name for the header metadata.
    private fun getAppVersionName(): String {
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION") packageManager.getPackageInfo(packageName, 0)
        }
        return packageInfo.versionName ?: "1.0"
    }

    // Forwards successful SDK capture results into the ViewModel.
    override fun onCaptureSuccess(result: com.contourdocumentimaging.android.contours_ai.models.ContoursResultModel) {
        viewModel.onCaptureSuccess(result)
    }

    // Receives raw SDK events for debugging without mixing them into UI state.
    override fun onEvent(eventJsonString: String) {
        println("---------- eventJsonString $eventJsonString")
    }

    // Forwards SDK close events into the ViewModel.
    override fun onClosed() {
        println("---------- SDK closed")
        viewModel.onSdkClosed()
    }

    // Forwards selfie-only results into the ViewModel.
    override fun onSelfieCaptured(imageUri: String?) {
        viewModel.onSelfieCaptured(imageUri)
    }
}
