package com.contoursai.android.example

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.contourdocumentimaging.android.contours_ai.constants.ContoursConstants
import com.contourdocumentimaging.android.contours_ai.models.ContoursResultModel

// Owns screen state and converts SDK results into UI state changes.
class MainViewModel : ViewModel() {

    private val _uiState = MutableLiveData(
        MainUiState(selectedTabId = ContourSdkConfig.defaultTabId, statusText = "Preparing scanner...")
    )
    val uiState: LiveData<MainUiState> = _uiState

    private var documentConfig = ContourSdkConfig.defaultDocument()

    // Switches the current document tab and emits a fresh UI state for that tab.
    fun selectTab(tabId: Int) {
        documentConfig = ContourSdkConfig.documentFor(tabId)
        _uiState.value = MainUiState(
            selectedTabId = tabId,
            titleRes = documentConfig.titleRes,
            descriptionRes = documentConfig.descriptionRes,
            frontLabelRes = documentConfig.frontLabelRes,
            backLabelRes = documentConfig.backLabelRes,
            showBackPreview = documentConfig.showBack,
            statusText = "Ready to scan ${documentConfig.displayName.lowercase()}."
        )
    }

    // Moves to the previous or next tab when the user swipes horizontally.
    fun moveTab(direction: Int) {
        val tabs = ContourSdkConfig.documents.map { it.tabId }
        val currentIndex = tabs.indexOf(_uiState.value?.selectedTabId ?: ContourSdkConfig.defaultTabId)
        val nextIndex = (currentIndex + direction).coerceIn(0, tabs.lastIndex)
        if (nextIndex != currentIndex) selectTab(tabs[nextIndex])
    }

    // Produces a scan request and updates the status before launching the SDK.
    fun prepareScan(isFront: Boolean): ContourSdkConfig.ScanRequest {
        val request = ContourSdkConfig.createScanRequest(documentConfig, isFront)
        updateState { copy(statusText = request.openingMessage) }
        return request
    }

    // Converts SDK capture results into UI state updates for previews and status.
    fun onCaptureSuccess(result: ContoursResultModel) {
        when {
            result.resultCheckFace.equals(ContoursConstants.FRONT_FACE, true) -> {
                updateState {
                    copy(
                        frontImageUri = result.resultFrontCroppedImageUri ?: frontImageUri,
                        backImageUri = result.resultRearCroppedImageUri ?: backImageUri,
                        statusText = if (!result.resultRearCroppedImageUri.isNullOrEmpty()) {
                            "${documentConfig.displayName} front and back scan completed."
                        } else {
                            "${documentConfig.displayName} front completed."
                        }
                    )
                }
            }
            result.resultCheckFace.equals(ContoursConstants.BACK_FACE, true) -> {
                updateState {
                    copy(
                        backImageUri = result.resultRearCroppedImageUri ?: backImageUri,
                        statusText = "${documentConfig.displayName} back scan completed."
                    )
                }
            }
            result.resultCheckFace.equals(ContoursConstants.FRONT_FACE_ONLY, true) -> {
                updateState {
                    copy(
                        frontImageUri = result.resultFrontCroppedImageUri ?: frontImageUri,
                        statusText = "${documentConfig.displayName} front face completed."
                    )
                }
            }
        }
    }

    // Marks the scan as closed only if no preview was captured.
    fun onSdkClosed() {
        val state = _uiState.value ?: return
        if (state.frontImageUri == null && state.backImageUri == null) {
            updateState { copy(statusText = "${documentConfig.displayName} scan closed.") }
        }
    }

    // Applies the selfie callback result to the shared UI state.
    fun onSelfieCaptured(imageUri: String?) {
        updateState { copy(frontImageUri = imageUri ?: frontImageUri, statusText = "Selfie completed.") }
    }

    // Rebuilds and emits UI state using the existing state as the base.
    private fun updateState(transform: MainUiState.() -> MainUiState) {
        _uiState.value = (_uiState.value ?: MainUiState()).transform()
    }
}
