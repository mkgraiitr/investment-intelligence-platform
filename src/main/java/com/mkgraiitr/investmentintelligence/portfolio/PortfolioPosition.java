package com.mkgraiitr.investmentintelligence.portfolio;

import java.math.BigDecimal;

public record PortfolioPosition(
        String symbol,
        String name,
        String assetType,
        String country,
        String sector,
        String bucket,
        BigDecimal quantity,
        BigDecimal averageCost,
        BigDecimal marketValue,
        String insightLabel
) {
}
