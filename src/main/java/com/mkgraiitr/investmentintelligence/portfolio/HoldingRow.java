package com.mkgraiitr.investmentintelligence.portfolio;

import java.math.BigDecimal;

public record HoldingRow(
        String symbol,
        String name,
        String assetType,
        String country,
        String bucket,
        BigDecimal quantity,
        BigDecimal averageCost,
        BigDecimal marketValue,
        BigDecimal portfolioPercentage,
        String insightLabel
) {
}
