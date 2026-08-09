package com.mkgraiitr.investmentintelligence.portfolio;

public record ReportVisualizationPreference(
        String visualizationKey,
        String displayName,
        String chartType,
        boolean visible,
        int displayOrder
) {
}
