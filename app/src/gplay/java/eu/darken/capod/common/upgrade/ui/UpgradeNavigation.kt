package eu.darken.capod.common.upgrade.ui

import androidx.navigation3.runtime.EntryProviderScope
import androidx.navigation3.runtime.NavKey
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dagger.multibindings.IntoSet
import eu.darken.capod.common.navigation.Nav
import eu.darken.capod.common.navigation.NavigationEntry
import eu.darken.capod.common.navigation.NavigationController
import javax.inject.Inject

class UpgradeNavigation @Inject constructor(private val navigation: NavigationController) : NavigationEntry {
    override fun EntryProviderScope<NavKey>.setup() {
        entry<Nav.Main.Upgrade> { UnlockedFeaturesScreen(onNavigateUp = { navigation.up() }) }
    }

    @Module
    @InstallIn(SingletonComponent::class)
    abstract class Mod {
        @Binds
        @IntoSet
        abstract fun bind(entry: UpgradeNavigation): NavigationEntry
    }
}
