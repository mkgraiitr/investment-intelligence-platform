package com.mkgraiitr.investmentintelligence.portfolio;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

@Service
public class PortfolioViewService {

    private static final BigDecimal ZERO = BigDecimal.ZERO;
    private static final int PERCENTAGE_SCALE = 6;

    private static final Map<String, String> BUCKET_COLORS = Map.of(
            "Core", "#1F5F99",
            "Satellite", "#D58A00",
            "Cash", "#129463",
            "Other", "#667383"
    );

    private static final List<String> PALETTE = List.of(
            "#1F5F99",
            "#D58A00",
            "#129463",
            "#6D4CA5",
            "#B6324B",
            "#6F879D",
            "#667383"
    );

    private final PortfolioReadRepository portfolioReadRepository;

    public PortfolioViewService(PortfolioReadRepository portfolioReadRepository) {
        this.portfolioReadRepository = portfolioReadRepository;
    }

    public PortfolioPageView personalModePortfolio() {
        var portfolio = portfolioReadRepository.findDefaultPortfolio()
                .orElseThrow(() -> new IllegalStateException("No active portfolio found. Seed data may not have been applied."));
        var positions = portfolioReadRepository.findPositions(portfolio.id());
        var reportPreferences = withFallbackPreferences(portfolioReadRepository.findReportPreferences(portfolio.id()));

        var totalMarketValue = sum(positions, PortfolioPosition::marketValue);
        var cashValue = sum(positions, position -> isCash(position) ? position.marketValue() : ZERO);
        var coreValue = sum(positions, position -> isBucket(position, "core") ? position.marketValue() : ZERO);
        var satelliteValue = sum(positions, position -> isBucket(position, "satellite") ? position.marketValue() : ZERO);

        var summary = new PortfolioSummary(
                portfolio.portfolioName(),
                portfolio.portfolioScope(),
                portfolio.primaryMarketCountry(),
                portfolio.baseCurrency(),
                benchmarkDisplayName(portfolio.primaryBenchmarkSymbol()),
                benchmarkDisplayName(portfolio.secondaryBenchmarkSymbol()),
                totalMarketValue,
                cashValue,
                percentage(cashValue, totalMarketValue),
                percentage(coreValue, totalMarketValue),
                percentage(satelliteValue, totalMarketValue)
        );

        var holdings = positions.stream()
                .map(position -> new HoldingRow(
                        position.symbol(),
                        position.name(),
                        displayName(position.assetType()),
                        emptyToDefault(position.country(), "Unassigned"),
                        displayName(position.bucket()),
                        position.quantity(),
                        position.averageCost(),
                        position.marketValue(),
                        percentage(position.marketValue(), totalMarketValue),
                        emptyToDefault(position.insightLabel(), "Track")
                ))
                .toList();

        var charts = reportPreferences.stream()
                .map(preference -> new ChartView(
                        preference.visualizationKey(),
                        preference.displayName(),
                        preference.chartType(),
                        preference.visible(),
                        preference.displayOrder(),
                        chartData(preference.visualizationKey(), positions, totalMarketValue)
                ))
                .toList();

        return new PortfolioPageView(summary, charts, holdings);
    }

    private List<ReportVisualizationPreference> withFallbackPreferences(List<ReportVisualizationPreference> reportPreferences) {
        if (!reportPreferences.isEmpty()) {
            return reportPreferences;
        }

        return List.of(
                new ReportVisualizationPreference("core_satellite_cash", "Core / Satellite / Cash", "donut", true, 1),
                new ReportVisualizationPreference("sector_allocation", "Sector Allocation", "donut", true, 2),
                new ReportVisualizationPreference("country_market_exposure", "Country / Market Exposure", "donut", true, 3),
                new ReportVisualizationPreference("holding_concentration", "Holding Concentration", "bar", true, 4)
        );
    }

    private List<AllocationSlice> chartData(String visualizationKey, List<PortfolioPosition> positions, BigDecimal totalMarketValue) {
        return switch (visualizationKey) {
            case "core_satellite_cash" -> bucketSlices(positions, totalMarketValue);
            case "sector_allocation" -> groupedSlices(positions, totalMarketValue, PortfolioPosition::sector);
            case "country_market_exposure" -> groupedSlices(positions, totalMarketValue, PortfolioPosition::country);
            case "holding_concentration" -> holdingSlices(positions, totalMarketValue);
            default -> List.of();
        };
    }

    private List<AllocationSlice> bucketSlices(List<PortfolioPosition> positions, BigDecimal totalMarketValue) {
        var bucketValues = new LinkedHashMap<String, BigDecimal>();
        bucketValues.put("Core", ZERO);
        bucketValues.put("Satellite", ZERO);
        bucketValues.put("Cash", ZERO);
        bucketValues.put("Other", ZERO);

        for (var position : positions) {
            var bucket = normalizedBucket(position);
            bucketValues.compute(bucket, (key, currentValue) -> currentValue.add(position.marketValue()));
        }

        return bucketValues.entrySet()
                .stream()
                .filter(entry -> entry.getValue().compareTo(ZERO) > 0)
                .map(entry -> new AllocationSlice(
                        entry.getKey(),
                        entry.getValue(),
                        percentage(entry.getValue(), totalMarketValue),
                        BUCKET_COLORS.getOrDefault(entry.getKey(), "#64748B")
                ))
                .toList();
    }

    private List<AllocationSlice> groupedSlices(
            List<PortfolioPosition> positions,
            BigDecimal totalMarketValue,
            Function<PortfolioPosition, String> classifier
    ) {
        var grouped = positions.stream()
                .collect(Collectors.groupingBy(
                        position -> emptyToDefault(classifier.apply(position), "Other"),
                        Collectors.mapping(PortfolioPosition::marketValue, Collectors.reducing(ZERO, BigDecimal::add))
                ));

        var ordered = grouped.entrySet()
                .stream()
                .sorted(Map.Entry.<String, BigDecimal>comparingByValue().reversed())
                .toList();

        var slices = new ArrayList<AllocationSlice>();
        for (var index = 0; index < ordered.size(); index++) {
            var entry = ordered.get(index);
            slices.add(new AllocationSlice(
                    entry.getKey(),
                    entry.getValue(),
                    percentage(entry.getValue(), totalMarketValue),
                    PALETTE.get(index % PALETTE.size())
            ));
        }

        return slices;
    }

    private List<AllocationSlice> holdingSlices(List<PortfolioPosition> positions, BigDecimal totalMarketValue) {
        var ordered = positions.stream()
                .sorted(Comparator.comparing(PortfolioPosition::marketValue).reversed())
                .toList();

        var slices = new ArrayList<AllocationSlice>();
        for (var index = 0; index < ordered.size(); index++) {
            var position = ordered.get(index);
            slices.add(new AllocationSlice(
                    position.symbol(),
                    position.marketValue(),
                    percentage(position.marketValue(), totalMarketValue),
                    PALETTE.get(index % PALETTE.size())
            ));
        }

        return slices;
    }

    private static BigDecimal sum(List<PortfolioPosition> positions, Function<PortfolioPosition, BigDecimal> valueExtractor) {
        return positions.stream()
                .map(valueExtractor)
                .reduce(ZERO, BigDecimal::add);
    }

    private static BigDecimal percentage(BigDecimal value, BigDecimal total) {
        if (total == null || total.compareTo(ZERO) == 0) {
            return ZERO.setScale(PERCENTAGE_SCALE, RoundingMode.HALF_UP);
        }

        return value.divide(total, PERCENTAGE_SCALE, RoundingMode.HALF_UP);
    }

    private static boolean isCash(PortfolioPosition position) {
        return isBucket(position, "cash") || "cash".equalsIgnoreCase(position.assetType());
    }

    private static boolean isBucket(PortfolioPosition position, String bucket) {
        return bucket.equalsIgnoreCase(position.bucket());
    }

    private static String normalizedBucket(PortfolioPosition position) {
        if (isCash(position)) {
            return "Cash";
        }
        if (isBucket(position, "core")) {
            return "Core";
        }
        if (isBucket(position, "satellite")) {
            return "Satellite";
        }
        return "Other";
    }

    private static String benchmarkDisplayName(String benchmarkSymbol) {
        return switch (emptyToDefault(benchmarkSymbol, "").toUpperCase(Locale.ROOT)) {
            case "NASDAQ_100_TR" -> "Nasdaq-100 Total Return";
            case "SP500_TR" -> "S&P 500 Total Return";
            default -> emptyToDefault(benchmarkSymbol, "Not configured");
        };
    }

    private static String displayName(String value) {
        var normalized = emptyToDefault(value, "Unassigned").replace('_', ' ').replace('-', ' ').trim();
        if (normalized.isBlank()) {
            return "Unassigned";
        }

        var words = normalized.split("\\s+");
        var displayName = new StringBuilder();
        for (var word : words) {
            if (!displayName.isEmpty()) {
                displayName.append(' ');
            }
            displayName.append(word.substring(0, 1).toUpperCase(Locale.ROOT));
            if (word.length() > 1) {
                displayName.append(word.substring(1).toLowerCase(Locale.ROOT));
            }
        }
        return displayName.toString();
    }

    private static String emptyToDefault(String value, String defaultValue) {
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
