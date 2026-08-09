package com.mkgraiitr.investmentintelligence.portfolio;

import java.math.BigDecimal;

public record AllocationSlice(
        String label,
        BigDecimal value,
        BigDecimal percentage,
        String color
) {
}
