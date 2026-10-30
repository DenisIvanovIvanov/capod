package eu.darken.capod.common.upgrade.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import eu.darken.capod.R

@Composable
fun UnlockedFeaturesScreen(onNavigateUp: () -> Unit) {
    Column(Modifier.fillMaxSize().padding(24.dp)) {
        Text(stringResource(R.string.unlocked_features_title))
        Text(stringResource(R.string.unlocked_features_description))
        Button(onClick = onNavigateUp) {
            Text(stringResource(android.R.string.ok))
        }
    }
}
