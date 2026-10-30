package eu.darken.capod.common.upgrade

import eu.darken.capod.BuildConfig
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOf
import java.time.Instant
import javax.inject.Inject
import javax.inject.Singleton

/** Feature access for this build is unconditional and does not depend on billing or donations. */
@Singleton
class UnlockedUpgradeRepo @Inject constructor() : UpgradeRepo {
    override val storeSite = "https://github.com/d4rken-org/capod/releases"
    override val upgradeSite = "https://github.com/sponsors/d4rken"
    override val betaSite = storeSite

    override val upgradeInfo: Flow<UpgradeRepo.Info> = flowOf(object : UpgradeRepo.Info {
        override val type = if (BuildConfig.FLAVOR == "gplay") UpgradeRepo.Type.GPLAY else UpgradeRepo.Type.FOSS
        override val isPro = true
        override val isSettled = true
        // Feature access is not a purchase; do not invent a purchase date or record.
        override val upgradedAt: Instant? = null
        override val error: Throwable? = null
    })

    override suspend fun refresh() = Unit
}
