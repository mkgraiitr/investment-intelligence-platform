package com.mkgraiitr.investmentintelligence.portfolio;

import java.math.BigDecimal;

public record PortfolioSummary(
        String portfolioName,
        String portfolioScope,
        String primaryMarketCountry,
        String baseCurrency,
        String primaryBenchmark,
        String secondaryBenchmark,
        BigDecimal totalMarketValue,
        BigDecimal cashValue,
        BigDecimal cashPercentage,
        BigDecimal corePercentage,
        BigDecimal satellitePercentage
) {
}
