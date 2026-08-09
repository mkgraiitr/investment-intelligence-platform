package com.mkgraiitr.investmentintelligence.portfolio;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PortfolioReadRepository {

    Optional<PortfolioRecord> findDefaultPortfolio();

    List<PortfolioPosition> findPositions(UUID portfolioId);

    List<ReportVisualizationPreference> findReportPreferences(UUID portfolioId);
}
