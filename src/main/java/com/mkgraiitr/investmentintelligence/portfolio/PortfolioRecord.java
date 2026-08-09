package com.mkgraiitr.investmentintelligence.portfolio;

import java.math.BigDecimal;
import java.util.UUID;

public record PortfolioRecord(
        UUID id,
        String portfolioName,
        String portfolioScope,
        String primaryMarketCountry,
        String baseCurrency,
        String primaryBenchmarkSymbol,
        String secondaryBenchmarkSymbol,
        BigDecimal cashTargetPercentage,
        BigDecimal satelliteMaxPercentage
) {
}
