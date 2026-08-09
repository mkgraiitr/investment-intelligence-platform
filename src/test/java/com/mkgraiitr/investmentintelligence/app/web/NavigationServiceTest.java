package com.mkgraiitr.investmentintelligence.app.web;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class NavigationServiceTest {

    @Test
    void mainNavigationMatchesPhaseOneInformationArchitecture() {
        var labels = new NavigationService().mainNavigation()
                .stream()
                .map(NavigationItem::label)
                .toList();

        assertThat(labels).containsExactly(
                "Home / Daily Brief",
                "Portfolio",
                "Discover",
                "Watchlist & Themes",
                "Research / Analysis Workspace",
                "Insights",
                "Intelligence",
                "Policy & Settings"
        );
    }
}
