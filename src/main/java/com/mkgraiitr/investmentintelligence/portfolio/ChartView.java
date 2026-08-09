package com.mkgraiitr.investmentintelligence.portfolio;

import java.util.List;

public record ChartView(
        String visualizationKey,
        String displayName,
        String chartType,
        boolean visible,
        int displayOrder,
        List<AllocationSlice> data
) {
}
