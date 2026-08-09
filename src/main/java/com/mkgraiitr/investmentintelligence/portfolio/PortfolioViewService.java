package com.mkgraiitr.investmentintelligence.portfolio;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class PortfolioViewService {

    public PortfolioPageView personalModePortfolio() {
        var summary = new PortfolioSummary(
                "US Portfolio",
                "country_specific",
                "US",
                "USD",
                "Nasdaq-100 Total Return",
                "S&P 500 Total Return",
                new BigDecimal("125000.00"),
                new BigDecimal("18750.00"),
                new BigDecimal("0.1500"),
                new BigDecimal("0.7200"),
                new BigDecimal("0.1300")
        );

        var charts = List.of(
                new ChartView(
                        "core_satellite_cash",
                        "Core / Satellite / Cash",
                        "donut",
                        true,
                        1,
                        List.of(
                                new AllocationSlice("Core", new BigDecimal("90000.00"), new BigDecimal("0.7200"), "#2563EB"),
                                new AllocationSlice("Satellite", new BigDecimal("16250.00"), new BigDecimal("0.1300"), "#7C3AED"),
                                new AllocationSlice("Cash", new BigDecimal("18750.00"), new BigDecimal("0.1500"), "#16A34A")
                        )
                ),
                new ChartView(
                        "sector_allocation",
                        "Sector Allocation",
                        "donut",
                        true,
                        2,
                        List.of(
                                new AllocationSlice("Technology", new BigDecimal("76000.00"), new BigDecimal("0.6080"), "#2563EB"),
                                new AllocationSlice("Communication", new BigDecimal("18000.00"), new BigDecimal("0.1440"), "#0891B2"),
                                new AllocationSlice("Cash", new BigDecimal("18750.00"), new BigDecimal("0.1500"), "#16A34A"),
                                new AllocationSlice("Other", new BigDecimal("12250.00"), new BigDecimal("0.0980"), "#64748B")
                        )
                ),
                new ChartView(
                        "country_market_exposure",
                        "Country / Market Exposure",
                        "donut",
                        true,
                        3,
                        List.of(
                                new AllocationSlice("US", new BigDecimal("106250.00"), new BigDecimal("0.8500"), "#2563EB"),
                                new AllocationSlice("Cash", new BigDecimal("18750.00"), new BigDecimal("0.1500"), "#16A34A")
                        )
                )
        );

        var holdings = List.of(
                new HoldingRow("AAPL", "Apple Inc.", "Stock", "US", "Core", new BigDecimal("10.5000"), new BigDecimal("175.2500"), new BigDecimal("21000.00"), new BigDecimal("0.1680"), "Track"),
                new HoldingRow("MSFT", "Microsoft Corporation", "Stock", "US", "Core", new BigDecimal("8.0000"), new BigDecimal("410.0000"), new BigDecimal("29600.00"), new BigDecimal("0.2368"), "Research Further"),
                new HoldingRow("QQQ", "Invesco QQQ Trust", "ETF", "US", "Core", new BigDecimal("35.0000"), new BigDecimal("440.0000"), new BigDecimal("32200.00"), new BigDecimal("0.2576"), "Track"),
                new HoldingRow("RKLB", "Rocket Lab USA Inc.", "Stock", "US", "Satellite", new BigDecimal("300.0000"), new BigDecimal("5.8000"), new BigDecimal("5250.00"), new BigDecimal("0.0420"), "High-Risk Tracking"),
                new HoldingRow("CASH", "Cash Reserve", "Cash", "US", "Cash", new BigDecimal("18750.0000"), BigDecimal.ONE, new BigDecimal("18750.00"), new BigDecimal("0.1500"), "Policy Warning")
        );

        return new PortfolioPageView(summary, charts, holdings);
    }
}
