package com.contoursai.android.example

// Represents the full render state for the main screen.
data class MainUiState(
    val selectedTabId: Int = R.id.check,
    val titleRes: Int = R.string.check_scan,
    val descriptionRes: Int = R.string.check_description,
    val frontLabelRes: Int = R.string.front_check,
    val backLabelRes: Int? = R.string.back_check,
    val showBackPreview: Boolean = true,
    val statusText: String = "",
    val frontImageUri: String? = null,
    val backImageUri: String? = null
)
