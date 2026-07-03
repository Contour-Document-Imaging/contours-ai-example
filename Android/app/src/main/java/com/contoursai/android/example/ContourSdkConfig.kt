package com.contoursai.android.example

import com.contourdocumentimaging.android.contours_ai.constants.ContoursConstants
import com.contourdocumentimaging.android.contours_ai.models.ContoursCapturingMode
import com.contourdocumentimaging.android.contours_ai.models.ContoursEnvironment
import com.contourdocumentimaging.android.contours_ai.models.ContoursModel
import com.contourdocumentimaging.android.contours_ai.models.ContoursScanType

// Central place for all Contour SDK configuration used by the screen.
object ContourSdkConfig {

    const val clientId = "<CLIENT_ID>"
    val defaultTabId = R.id.check

    val documents = listOf(
        DocumentConfig(
            tabId = R.id.check,
            docType = ContoursScanType.CHECK,
            titleRes = R.string.check_scan,
            descriptionRes = R.string.check_description,
            frontLabelRes = R.string.front_check,
            backLabelRes = R.string.back_check,
            showBack = true,
            displayName = "Check",
            capturingMode = ContoursCapturingMode.BOTH_CAPTURE,
            frontCheckFace = ContoursConstants.FRONT_FACE,
            backCheckFace = ContoursConstants.BACK_FACE
        ),
        DocumentConfig(
            tabId = R.id.id,
            docType = ContoursScanType.ID,
            titleRes = R.string.id_scan,
            descriptionRes = R.string.id_description,
            frontLabelRes = R.string.front_id,
            backLabelRes = R.string.back_id,
            showBack = true,
            displayName = "ID",
            capturingMode = ContoursCapturingMode.BOTH_CAPTURE,
            frontCheckFace = ContoursConstants.FRONT_FACE,
            backCheckFace = ContoursConstants.BACK_FACE
        ),
        DocumentConfig(
            tabId = R.id.passport,
            docType = ContoursScanType.PASSPORT,
            titleRes = R.string.passport_scan,
            descriptionRes = R.string.passport_description,
            frontLabelRes = R.string.passport_front_face,
            backLabelRes = null,
            showBack = false,
            displayName = "Passport",
            capturingMode = ContoursCapturingMode.BOTH_CAPTURE,
            frontCheckFace = ContoursConstants.FRONT_FACE
        ),
        DocumentConfig(
            tabId = R.id.selfie,
            docType = ContoursScanType.SELFIE,
            titleRes = R.string.selfie_scan,
            descriptionRes = R.string.selfie_description,
            frontLabelRes = R.string.user_selfie,
            backLabelRes = null,
            showBack = false,
            displayName = "Selfie",
            capturingMode = ContoursCapturingMode.BOTH_CAPTURE,
            frontCheckFace = ContoursConstants.FRONT_FACE
        )
    )

    // Returns the SDK document configuration for the selected tab.
    fun defaultDocument() = documentFor(defaultTabId)

    fun documentFor(tabId: Int) = documents.firstOrNull { it.tabId == tabId } ?: documents.first { it.tabId == defaultTabId }

    // Builds the SDK scan request for the selected document and side.
    fun createScanRequest(document: DocumentConfig, isFront: Boolean): ScanRequest {
        val checkFace = if (isFront) document.frontCheckFace else document.backCheckFace ?: document.frontCheckFace
        val sideLabel = when {
            document.docType == ContoursScanType.PASSPORT -> "front face"
            document.docType == ContoursScanType.SELFIE -> "face"
            isFront -> "front"
            else -> "back"
        }
        return ScanRequest(document, document.capturingMode, checkFace, "Opening $sideLabel...")
    }

    // Creates the final SDK model object from a prepared scan request.
    fun createContoursModel(scanRequest: ScanRequest) = ContoursModel().apply {
        capturingMode = scanRequest.capturingMode
        checkFace = scanRequest.checkFace
        type = scanRequest.document.docType
        capturingSide = scanRequest.checkFace
    }

    // Defines all SDK-related settings for a single document flow.
    data class DocumentConfig(
        val tabId: Int,
        val docType: ContoursScanType = ContoursScanType.CHECK,
        val titleRes: Int,
        val descriptionRes: Int,
        val frontLabelRes: Int,
        val backLabelRes: Int?,
        val showBack: Boolean,
        val displayName: String,
        val capturingMode: ContoursCapturingMode = ContoursCapturingMode.BOTH_CAPTURE,
        val frontCheckFace: String = ContoursConstants.FRONT_FACE,
        val backCheckFace: String? = null
    )

    // Carries the exact request data needed to launch the SDK.
    data class ScanRequest(
        val document: DocumentConfig,
        val capturingMode: ContoursCapturingMode,
        val checkFace: String,
        val openingMessage: String
    )
}
