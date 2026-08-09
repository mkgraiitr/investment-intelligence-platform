package com.mkgraiitr.investmentintelligence.portfolio;

import java.util.List;

public record PortfolioPageView(
        PortfolioSummary summary,
        List<ChartView> charts,
        List<HoldingRow> holdings
) {
}
