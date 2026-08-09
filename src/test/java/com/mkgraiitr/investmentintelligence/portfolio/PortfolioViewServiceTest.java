package com.mkgraiitr.investmentintelligence.portfolio;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;

class PortfolioViewServiceTest {

    @Test
    void personalModePortfolioStartsWithConfiguredPolicyShape() {
        var view = new PortfolioViewService().personalModePortfolio();

        assertThat(view.summary().portfolioName()).isEqualTo("US Portfolio");
        assertThat(view.summary().primaryBenchmark()).isEqualTo("Nasdaq-100 Total Return");
        assertThat(view.summary().cashPercentage()).isEqualByComparingTo(new BigDecimal("0.1500"));
        assertThat(view.summary().satellitePercentage()).isEqualByComparingTo(new BigDecimal("0.1300"));
        assertThat(view.charts()).extracting(ChartView::visualizationKey)
                .containsExactly("core_satellite_cash", "sector_allocation", "country_market_exposure");
        assertThat(view.holdings()).extracting(HoldingRow::symbol)
                .contains("AAPL", "MSFT", "QQQ", "RKLB", "CASH");
    }
}
