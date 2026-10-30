package eu.darken.capod.common.upgrade

import io.kotest.matchers.shouldBe
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test

class UnlockedUpgradeRepoTest {
    @Test
    fun `features are available immediately and after refresh without a purchase`() = runTest {
        val repo = UnlockedUpgradeRepo()
        repeat(2) {
            repo.upgradeInfo.first().apply {
                isPro shouldBe true
                isSettled shouldBe true
                upgradedAt shouldBe null
                error shouldBe null
            }
            repo.isPro() shouldBe true
            repo.isProForUi() shouldBe true
            repo.isProSettled() shouldBe true
            repo.refresh()
        }
    }
}
