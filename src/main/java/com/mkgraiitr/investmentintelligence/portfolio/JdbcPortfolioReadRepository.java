package com.mkgraiitr.investmentintelligence.portfolio;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class JdbcPortfolioReadRepository implements PortfolioReadRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    public JdbcPortfolioReadRepository(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public Optional<PortfolioRecord> findDefaultPortfolio() {
        var records = jdbcTemplate.query(
                """
                SELECT
                    p.id,
                    p.name,
                    p.portfolio_scope,
                    p.primary_market_country,
                    p.base_currency,
                    p.primary_benchmark_symbol,
                    p.secondary_benchmark_symbol,
                    policy.cash_target_percentage,
                    policy.satellite_max_percentage
                FROM portfolios p
                LEFT JOIN LATERAL (
                    SELECT
                        pv.cash_target_percentage,
                        pv.satellite_max_percentage
                    FROM policy_profiles pp
                    JOIN policy_versions pv ON pv.policy_profile_id = pp.id
                    WHERE pp.portfolio_id = p.id
                      AND pp.status = 'active'
                      AND pv.is_active = true
                    ORDER BY pv.effective_from DESC, pv.created_at DESC
                    LIMIT 1
                ) policy ON true
                WHERE p.status = 'active'
                ORDER BY p.created_at
                LIMIT 1
                """,
                Map.of(),
                this::mapPortfolio
        );

        return records.stream().findFirst();
    }

    @Override
    public List<PortfolioPosition> findPositions(UUID portfolioId) {
        return jdbcTemplate.query(
                """
                WITH latest_valuations AS (
                    SELECT DISTINCT ON (holding_id)
                        holding_id,
                        market_value
                    FROM holding_valuation_snapshots
                    ORDER BY holding_id, valuation_date DESC, created_at DESC
                ),
                latest_insights AS (
                    SELECT DISTINCT ON (asset_id)
                        asset_id,
                        label
                    FROM insights
                    WHERE portfolio_id = :portfolioId
                      AND asset_id IS NOT NULL
                      AND status = 'active'
                    ORDER BY asset_id, generated_at DESC, created_at DESC
                )
                SELECT
                    a.symbol,
                    a.name,
                    a.asset_type,
                    COALESCE(a.country, p.primary_market_country, 'Unassigned') AS country,
                    COALESCE(a.sector, 'Other') AS sector,
                    h.portfolio_bucket,
                    h.quantity,
                    h.average_cost,
                    COALESCE(v.market_value, h.cost_basis, h.quantity * h.average_cost, 0) AS market_value,
                    COALESCE(
                        i.label,
                        CASE lower(h.portfolio_bucket)
                            WHEN 'satellite' THEN 'High-Risk Tracking'
                            WHEN 'cash' THEN 'Policy Warning'
                            ELSE 'Track'
                        END
                    ) AS insight_label
                FROM holdings h
                JOIN portfolios p ON p.id = h.portfolio_id
                JOIN assets a ON a.id = h.asset_id
                LEFT JOIN latest_valuations v ON v.holding_id = h.id
                LEFT JOIN latest_insights i ON i.asset_id = a.id
                WHERE h.portfolio_id = :portfolioId
                ORDER BY
                    CASE lower(h.portfolio_bucket)
                        WHEN 'core' THEN 1
                        WHEN 'satellite' THEN 2
                        WHEN 'cash' THEN 3
                        ELSE 4
                    END,
                    a.symbol
                """,
                Map.of("portfolioId", portfolioId),
                this::mapPosition
        );
    }

    @Override
    public List<ReportVisualizationPreference> findReportPreferences(UUID portfolioId) {
        return jdbcTemplate.query(
                """
                SELECT
                    visualization_key,
                    display_name,
                    chart_type,
                    is_visible,
                    display_order
                FROM portfolio_report_preferences
                WHERE portfolio_id = :portfolioId
                  AND report_key = 'overview'
                ORDER BY display_order, display_name
                """,
                Map.of("portfolioId", portfolioId),
                this::mapReportPreference
        );
    }

    private PortfolioRecord mapPortfolio(ResultSet rs, int rowNumber) throws SQLException {
        return new PortfolioRecord(
                rs.getObject("id", UUID.class),
                rs.getString("name"),
                rs.getString("portfolio_scope"),
                rs.getString("primary_market_country"),
                rs.getString("base_currency"),
                rs.getString("primary_benchmark_symbol"),
                rs.getString("secondary_benchmark_symbol"),
                valueOrZero(rs, "cash_target_percentage"),
                valueOrZero(rs, "satellite_max_percentage")
        );
    }

    private PortfolioPosition mapPosition(ResultSet rs, int rowNumber) throws SQLException {
        return new PortfolioPosition(
                rs.getString("symbol"),
                rs.getString("name"),
                rs.getString("asset_type"),
                rs.getString("country"),
                rs.getString("sector"),
                rs.getString("portfolio_bucket"),
                valueOrZero(rs, "quantity"),
                valueOrZero(rs, "average_cost"),
                valueOrZero(rs, "market_value"),
                rs.getString("insight_label")
        );
    }

    private ReportVisualizationPreference mapReportPreference(ResultSet rs, int rowNumber) throws SQLException {
        return new ReportVisualizationPreference(
                rs.getString("visualization_key"),
                rs.getString("display_name"),
                rs.getString("chart_type"),
                rs.getBoolean("is_visible"),
                rs.getInt("display_order")
        );
    }

    private static BigDecimal valueOrZero(ResultSet rs, String columnName) throws SQLException {
        var value = rs.getBigDecimal(columnName);
        return value == null ? BigDecimal.ZERO : value;
    }
}
