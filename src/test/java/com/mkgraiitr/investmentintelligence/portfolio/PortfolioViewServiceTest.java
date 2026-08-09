package com.mkgraiitr.investmentintelligence.portfolio;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;

class PortfolioViewServiceTest {

    private static final UUID PORTFOLIO_ID = UUID.fromString("00000000-0000-0000-0000-000000000301");

    @Test
    void personalModePortfolioBuildsViewFromRepositoryData() {
        var view = new PortfolioViewService(new FakePortfolioReadRepository()).personalModePortfolio();

        assertThat(view.summary().portfolioName()).isEqualTo("US Portfolio");
        assertThat(view.summary().primaryBenchmark()).isEqualTo("Nasdaq-100 Total Return");
        assertThat(view.summary().totalMarketValue()).isEqualByComparingTo(new BigDecimal("125000.000000"));
        assertThat(view.summary().cashPercentage()).isEqualByComparingTo(new BigDecimal("0.150000"));
        assertThat(view.summary().corePercentage()).isEqualByComparingTo(new BigDecimal("0.720000"));
        assertThat(view.summary().satellitePercentage()).isEqualByComparingTo(new BigDecimal("0.130000"));
        assertThat(view.charts()).extracting(ChartView::visualizationKey)
                .containsExactly("core_satellite_cash", "sector_allocation", "country_market_exposure", "holding_concentration");
        assertThat(view.holdings()).extracting(HoldingRow::symbol)
                .containsExactly("AAPL", "MSFT", "QQQ", "RKLB", "CASH");
    }

    private static class FakePortfolioReadRepository implements PortfolioReadRepository {

        @Override
        public Optional<PortfolioRecord> findDefaultPortfolio() {
            return Optional.of(new PortfolioRecord(
                    PORTFOLIO_ID,
                    "US Portfolio",
                    "country_specific",
                    "US",
                    "USD",
                    "NASDAQ_100_TR",
                    "SP500_TR",
                    new BigDecimal("0.150000"),
                    new BigDecimal("0.200000")
            ));
        }

        @Override
        public List<PortfolioPosition> findPositions(UUID portfolioId) {
            assertThat(portfolioId).isEqualTo(PORTFOLIO_ID);
            return List.of(
                    new PortfolioPosition("AAPL", "Apple Inc.", "stock", "US", "Technology", "core", new BigDecimal("93.33333333"), new BigDecimal("175.250000"), new BigDecimal("21000.000000"), "Track"),
                    new PortfolioPosition("MSFT", "Microsoft Corporation", "stock", "US", "Technology", "core", new BigDecimal("61.66666667"), new BigDecimal("410.000000"), new BigDecimal("29600.000000"), "Research Further"),
                    new PortfolioPosition("QQQ", "Invesco QQQ Trust", "etf", "US", "ETF", "core", new BigDecimal("78.80000000"), new BigDecimal("440.000000"), new BigDecimal("39400.000000"), "Track"),
                    new PortfolioPosition("RKLB", "Rocket Lab USA Inc.", "stock", "US", "Industrials", "satellite", new BigDecimal("1250.00000000"), new BigDecimal("5.800000"), new BigDecimal("16250.000000"), "High-Risk Tracking"),
                    new PortfolioPosition("CASH", "Cash Reserve", "cash", "US", "Cash", "cash", new BigDecimal("18750.00000000"), BigDecimal.ONE, new BigDecimal("18750.000000"), "Policy Warning")
            );
        }

        @Override
        public List<ReportVisualizationPreference> findReportPreferences(UUID portfolioId) {
            assertThat(portfolioId).isEqualTo(PORTFOLIO_ID);
            return List.of(
                    new ReportVisualizationPreference("core_satellite_cash", "Core / Satellite / Cash", "donut", true, 1),
                    new ReportVisualizationPreference("sector_allocation", "Sector Allocation", "donut", true, 2),
                    new ReportVisualizationPreference("country_market_exposure", "Country / Market Exposure", "donut", true, 3),
                    new ReportVisualizationPreference("holding_concentration", "Holding Concentration", "bar", true, 4)
            );
        }
    }
}
